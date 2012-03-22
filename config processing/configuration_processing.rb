##!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

begin
  require 'rubygems'
rescue LoadError
  $stderr.puts "#{$0} requires installed rubygems\n"
  exit -1
end

begin
  require 'libxml'
rescue LoadError
  $stderr.puts "#{$0} requires installed libxml-ruby ruby gem\nTry $ sudo gems install -r libxml-ruby\n"
  exit -1
end

include LibXML::XML

=begin

=end
class ConfigurationProcessing
  attr_reader :tdoc_n, :conf_n, :odoc_n, :tdoc, :conf, :odoc, :xml_elements, :multiple_elements, :out_js

  @@Elements_type = %w[checkboxes selects texts text_areas file morphology]

  def Elements_type
    @@Elements_type
  end

  @@Template_s = <<-EOS
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <title></title>
      <link rel="stylesheet" type="text/css" href="style/editor.css"/>
    </head>
    <body>
      <fieldset class="editor">
        <legend onclick="hide('editor_content')">Editor</legend>
        <div id="editor_content">
          <label>Autor: <span id="author_id" class="author"></span></label> <label>ID: <span id="entry_id" class="entry"></span></label><br/>
        </div>
      </fieldset>
      <fieldset class="entry_list">
        <legend id="entry_list_legend" onclick="hide('entry_list_content')"></legend>
        <div id="entry_list_content">
        </div>
      </fieldset>
    </body>
  </html>
  EOS

  def initialize(conf_n, odoc_n, tdoc_n = nil)
    @tdoc_n = tdoc_n
    @conf_n = conf_n
    @odoc_n = odoc_n
    @odoc_n += '.html' if @odoc_n[-5..-1].nil? or @odoc_n[-5..-1] != '.html'
    @conf = Document.file(@conf_n)
    @odoc = @tdoc_n.nil? ? Document.string(@@Template_s) : HTMLParser.file(@tdoc_n).parse

    @out_js = ''

    @multiple_elements = []
    @xml_elements = {}
    @@Elements_type.each do |e|
      case e
        when 'selects', 'texts', 'text_areas'
          @xml_elements[e.to_sym] = []
        when 'checkboxes', 'file'
          @xml_elements[e.to_sym] = {}
        else
      end
    end

    process_conf()

    #puts @odoc.save(@odoc_n+'.html')
  end

  #
  #
  #
  def tdoc
    @tdoc_n.nil? ? @@Template_s : Document.file(@tdoc_n).to_s
  end

  def save()
    out_js = File.new(@odoc_n[0...-5] + '_vars.js', "w")
    out_js << @out_js
    out = File.new(@odoc_n, "w")
    out << @odoc.to_s
  end

  #
  #
  #
  def process_conf()
    # uzol head elementu stranky
    head_node = @odoc.find_first('//head')
    js = Node.new 'script'
    js['type'] = 'text/javascript'
    js['src'] = @odoc_n[0...-5] + '_vars.js'
    head_node << js

    js = Node.new 'script'
    js['type'] = 'text/javascript'
    js['src'] = 'script/jquery-1.7.1.js'
    head_node << js

    js = Node.new 'script'
    js['type'] = 'text/javascript'
    js['src'] = 'script/event_handlers_jquery.js'
    head_node << js

    # uzol s obsahom editora, do ktoreho sa bude pridavat
    ed_node = @odoc.find_first('//div[@id="editor_content"]')

    # obsahovy uzol editora z xml konfiguracneho subora
    content_node = @conf.find_first('//content')

    # spracovanie kazdeho input elementu z konfiguracie a pridanie ho do editora
    content_node.each_element do |input|
      # pridanie kazdeho spracovaneho uzlu
      ed_node << pr_input(input)
    end

    database_name_node = @conf.find_first('//database/name')
    @odoc.find_first('//head/title') << database_name_node.content

    div = Node.new 'div'
    div['class'] = 'buttons'
    but = Node.new 'button'
    but << Node.new_text('Save')
    ed_node << (div << but)



    xml_elements = pr_out_xml_elements()
    multiple_elements = pr_out_multiple_elements()
    @out_js += "var xml_data = #{xml_elements};\nvar multiple_el = #{multiple_elements};"

  end

  #
  # Spracovana input elementy z konfiguracie. Novovytvoreny uzol vracia.
  #
  def pr_input(input)
    # kontrola aby neboli chybne pridane textove uzly,
    # ktore sa mozu vyskytovat medzi input uzlami
    if input.name != 'input'
      return nil
    end
    
    div = Node.new 'div'
    div['class'] = 'input'
    label = Node.new 'label'
    label << Node.new_text(input['label'])
    div << label
    
    # potomkovia input elementu
    children = input.children
   
    res = nil
    children.each() do |t|
      if t.node_type_name() == 'element' # != 'text' and t.node_type_name() != 'comment'
        # puts t.node_type_name
        case t.name()
          when 'select'
            res = pr_select(t)
          when 'text'
            res = pr_text(t)
          when 'textarea'
            res = pr_textarea(t)
          when 'checkboxes'
            res = pr_checkboxes(t)
          when 'file'
            res = pr_file(t)
          when 'morphology'
            res = pr_morphology(t)
        end
      end
    end
    
    div << res
  end
  
  def pr_select(node)
    div = Node.new 'div'
    div['class'] = 'select_el'
    
    # vytvorenie select elementu
    select = Node.new 'select'
    select['name'] = node['name']
    if node['multiple'] == 'true'
      select['multiple'] = 'multiple'
    end

    @xml_elements[:selects] << select['name']
    
    # pridanie option elementov do selectu
    node.children.each do |option|
      if option.node_type_name() != 'text' and option.node_type_name() != 'comment' and option.name() == 'option'
        op = Node.new 'option'
        op['value'] = option['value']
        op << Node.new_text(option['label'])
        select << op
      end
    end
    
    div << select
  end
  
  def pr_text(node)
    div = Node.new 'div'
    div['class'] = 'text_el'
    
    node.children.each do |tfs|
      if tfs.node_type_name() == 'element'
        
        if tfs.name() == 'textFields'
          
          tfs.children.each do |tf|
            if tf.node_type_name() == 'element'
              label = Node.new 'label'
              label['for'] = tf['name'] + '_id'
              label << Node.new_text(tf['label'])
              div << label
              input = Node.new 'input'
              input['type'] = 'text'
              input['id'] = tf['name'] + '_id'
              input['name'] = tf['name']

              @xml_elements[:texts] << tf['name']

              div << input
            end
          end
        elsif tfs.name() == 'textField'
          text_div = Node.new 'div'
          input = Node.new 'input'
          input['type'] = 'text'
          input['name'] = tfs['name']
          text_div << input

          @xml_elements[:texts] << tfs['name']
          if tfs['multiple'] == 'true'
            @multiple_elements << tfs['name']
            #but = Node.new 'button'
            #but['class'] = 'button multiple'
            #but['width'] = but['height'] = '28'
            img = Node.new 'img'
            img['src'] = 'images/add.png'
            img['alt'] = 'add text field'
            img['class'] = 'multiple'
            #img['width'] = img['height'] = '20'
            #div << (text_div << (but << img))
            div << (text_div << img)
          end
        end
        
      end
    end
    
    div
  end 
  
  def pr_textarea(node)
    div = Node.new 'div'
    div['class'] = 'textarea_el'

    textarea = Node.new 'textarea'
    textarea['name'] = node['name']
    textarea['rows'] = '3'
    textarea['cols'] = '50'

    @xml_elements[:text_areas] << node['name']
      
    div << textarea
  end
  
  def pr_checkboxes(node)
    div = Node.new 'div'
    div['class'] = 'checkboxes'
    
    node.find('checkbox').each do |cb|
      label = Node.new 'label'
      label['for'] = cb['name'] + '_id'
      label << Node.new_text(cb['label'])
      div << label
      checkbox = Node.new 'input'
      checkbox['class'] = 'checkbox'
      checkbox['type'] = 'checkbox'
      checkbox['id'] = cb['name'] + '_id'
      checkbox['name'] = cb['name']

      @xml_elements[:checkboxes][cb['name']] = cb['asAttr']
      div << checkbox
    end
    
    div
  end  
  
  def pr_file(node)
    div = Node.new 'div'
    div['class'] = 'file_el'
    file = Node.new 'input'
    file['type'] = 'text'
    file['name'] = 'file'
    #file['id'] = 'file' + '_id'

    div2 = Node.new 'div'

    div2 << file

    @multiple_elements << 'file' if node['multiple'].downcase == 'true'
    @xml_elements[:file][:occurrence] = true
    @xml_elements[:file][:multiple] = node['multiple']

    #but = Node.new 'button'
    #but['class'] = 'button'
    img = Node.new 'img'
    img['src'] = 'images/file_add.png'
    img['alt'] = '+'
    img['class'] = 'add_file'
    div2 << img if node['multiple'].downcase == 'true'
    #but << img
    #div << but
    
    #but = Node.new 'button'
    #but['class'] = 'button'
    img = Node.new 'img'
    img['src'] = 'images/file.png'
    img['alt'] = 'show'
    #but << img
    #div << but
    div2 << img
    
    #but = Node.new 'button'
    #but['class'] = 'button'
    img = Node.new 'img'
    img['src'] = 'images/file_search.png'
    img['alt'] = 'search'
    #but << img
    #div << but
    div2 << img

    div << div2
  end

  def pr_morphology(node)
    div = Node.new 'div'
    div['class'] = 'morphology_el'
    morf = Node.new 'input'
    morf['type'] = 'text'
    #morf['id'] = node['name'] + '_id'
    morf['name'] = node['name']
    morf['morph_for'] = node[:morph_for]

    @xml_elements[:morphology] = true
    div << morf
    
    #but = Node.new 'button'
    #but['class'] = 'button'
    img = Node.new 'img'
    img['src'] = 'images/info.png'
    img['alt'] = 'display'

    div << img
    #but << img
    #div << but
  end

  def pr_out_xml_elements
    out_str = ""
    checkboxes = ""
    @xml_elements.keys.each do |el_type|

      case el_type
        when :selects, :texts, :text_areas
          @xml_elements[el_type].each do |el|
            if !out_str.empty?
              out_str = "#{out_str}, \"#{el}\""
            else
              out_str = "\"#{el}\""
            end
          end

        when :checkboxes
          @xml_elements[el_type].keys.each do |name|
            if !checkboxes.empty?
              checkboxes = "#{checkboxes}, { \"name\": \"#{name}\", \"asAttr\": \"#{@xml_elements[el_type][name]}\" }"
            else
              checkboxes = "{ \"name\": \"#{name}\", \"asAttr\": \"#{@xml_elements[el_type][name]}\" }"
            end
          end

        when :file
          if @xml_elements[el_type][:occurrence]
            if !out_str.empty?
              out_str = "#{out_str}, \"file\""
            else
              out_str = "\"file\""
            end
          end

      end

    end

    out_str = "[ #{out_str}#{", { \"checkboxes\": [ #{checkboxes} ] }" unless checkboxes.empty?} ]"
    #puts out_str

    out_str
  end

  def pr_out_multiple_elements
    out_str = ""
    @multiple_elements.each do |el|
      out_str += out_str.empty? ? "\"#{el}\"" : ", \"#{el}\""
    end
    out_str = "[ #{out_str} ]"
    #puts out_str

    out_str
  end

  private :process_conf, :pr_input, :pr_select, :pr_text, :pr_textarea, :pr_checkboxes, :pr_file, :pr_morphology, :pr_out_xml_elements
  
end

if __FILE__ == $0
  
  if ARGV.length != 3 and ARGV.length != 2
    $stderr.puts "Usage: $ ruby #{$0.gsub(/ /, "\\ ")} configuration_xml_file_name output_html_file_name [template_html_file_name]\n"
    exit -1
  end
  
  if ARGV.length == 3
    con = ConfigurationProcessing.new(ARGV[0], ARGV[1], ARGV[2])
    con.save()
    #puts con.odoc
    #puts con.xml_elements
  elsif ARGV.length == 2
    con = ConfigurationProcessing.new(ARGV[0], ARGV[1])
    con.save()
    #puts con.odoc
    #puts con.xml_elements
  end

end
