function add_element(event)
{
    var new_el = $(event.target.parentElement).clone();
    $('img', new_el).attr('src', 'images/delete.png')
        .unbind('click')
        .click(remove_element);
    $(event.target.parentElement.parentElement).append(new_el);
};

function remove_element(event)
{
    $(event.target.parentElement).remove();
};

function add_file_element(event)
{
    var new_el = $(event.target.parentElement).clone();
    $('img.add_file', new_el).removeClass('add_file')
        .addClass('remove_file')
        .attr('src', 'images/file_delete.png')
        .unbind('click')
        .click(remove_element);
    $(event.target.parentElement.parentElement).append(new_el);
};

/* add listeners to editor's element */
$(document).ready(function add_listeners() {
    /* add click listener to multiple text inputs */
    $('img.multiple').click(add_element);

    /* add click listeners to file input*/
    $('img.add_file').click(add_file_element);
//    alert($('img[src="images/file_search.png"]').get());
    $('img[src="images/file_search.png"]').click(function() {
        alert('file_search.png');
    });
});
