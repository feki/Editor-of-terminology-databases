var add_element = function(event)
{
    var old = event.target.parentElement;
    var parent = old.parentElement;
    var old_input = old.getElementsByTagName('input')[0];
    var div = document.createElement('div');
    var input = document.createElement('input');
    input.setAttribute('type', old_input.getAttribute('type'));
    input.setAttribute('name', old_input.getAttribute('name'));
    div.appendChild(input);
//    var button = document.createElement('button');
//    button.setAttribute('class', 'button');
    var img = document.createElement('img');
    img.setAttribute('src', 'images/delete.png');
    div.appendChild(img);
//    button.appendChild(img);
//    div.appendChild(button);
    parent.appendChild(div);
//    button.addEventListener("click", remove_element);
    img.addEventListener("click", remove_element);
};

var remove_element = function(event)
{
    var old = event.target.parentElement;
    var parent = old.parentElement;
    parent.removeChild(old);
};

var add_file_element = function(event)
{
    var old = event.target.parentElement;
    var parent = old.parentElement;
    var old_input = old.getElementsByTagName('input')[0];
    var div = document.createElement('div');
    var input = document.createElement('input');
    input.setAttribute('type', old_input.getAttribute('type'));
    input.setAttribute('name', old_input.getAttribute('name'));
    div.appendChild(input);

    var img = document.createElement('img');
    img.setAttribute('src', 'images/file_delete.png');
    img.addEventListener('click', remove_element);
    div.appendChild(img);

    img = document.createElement('img');
    img.setAttribute('src', 'images/file.png');
    div.appendChild(img);

    img = document.createElement('img');
    img.setAttribute('src', 'images/file_search.png');
    div.appendChild(img);

    parent.appendChild(div);
};

function add_listeners()
{
    var multiples = document.getElementsByClassName('multiple');
//    alert(multiples);
    for(var i = 0; i < multiples.length; i++) {
        multiples[i].addEventListener('click', add_element, false);
    }

    var file = document.getElementsByClassName('add_file')[0];
    file.addEventListener('click', add_file_element, false);
};
