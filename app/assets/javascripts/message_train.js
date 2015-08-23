//= require bootstrap-tags

function create_alert(level, message) {
    $('#alert_area').append('<div class="alert alert-' + level + ' alert-dismissible fade in" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">×</span></button>' + message + ' </div>');
}

function set_and_change(selector, value) {
    $(selector).prop('checked', value).trigger("change");
}

function flicker(selector, count) {
    $(selector).addClass('flicker')
        .delay(100)
        .queue(function() {
            $(this).removeClass('flicker');
            $(this).dequeue();
        })
        .delay(100)
        .queue(function() {
            if(count > 1) {
                flicker(selector, count - 1);
            } else {
                flick_out(selector);
            }
            $(this).dequeue();
        });
}

function flick_out(selector) {
    $(selector).addClass('flicker')
        .delay(100)
        .queue(function() {
            $(this).addClass('flicker-out');
            $(this).dequeue();
        }).delay(1000)
        .queue(function() {
            $(this).removeClass('flicker').removeClass('flicker-out');
            $(this).dequeue();
        })
}

function replace_via_ajax(selector, path) {
    $.getJSON( path, function( data ) {
        $(selector).replaceWith(data.html);
        flicker(selector, 3);
    });
}

function process_results(data) {
    if(typeof data.results === 'undefined' || data.results.length == 0) {
        create_alert('warning', data.message);
    } else {
        create_alert('info', data.message);
        for(var key in data.results) {
            var item = data.results[key];
            replace_via_ajax('#' + item.css_id, item.path);
        }
    }
}

function add_tag_magic(node) {
    div = $(node);
    $.getJSON('/box/in/participants.json', function(data){
        input = div.children('input');
        form = div.parents('form');
        var suggestions = [];
        $.each(data.participants, function (i, participant) {
            suggestions.push(participant.slug);
        });
        tags = div.tags({
            suggestions: suggestions,
            tagSize: 'lg',
            promptText: 'Comma separated list'
        });
        form.submit(function(e) {
            field_template = '<input name="' + div.data('field-name') + '" value="' + tags.getTags() + '" type="hidden">';
            form.append(field_template);
            return true;
        });
    });
}

$(document).ready(function(){

    $('.message_train_conversation input[type="checkbox"]').change(function(event) {
        if (event.target.checked) {
            //Checkbox has been checked
            $(this).parents('.message_train_conversation').addClass('selected');
        } else {
            //Checkbox has been unchecked
            $(this).parents('.message_train_conversation').removeClass('selected');
        }
    });
    $('#check_all').change(function(event) {
        if (event.target.checked) {
            set_and_change( '.message_train_conversation input[type="checkbox"]', true);
        } else {
            set_and_change( '.message_train_conversation input[type="checkbox"]', false);
        }
    });
    $('#box-actions .check').click(function(event) {
        event.preventDefault();
        selector = $(this).data('selector');
        set_and_change( '.message_train_conversation input[type="checkbox"]', false);
        if(selector == '.message_train_conversation') {
            $('#check_all').prop('checked', true);
        } else {
            $('#check_all').prop('checked', false);
        }
        if(selector != '') {
            set_and_change( selector + ' input[type="checkbox"]', true);
        }
    });
    $('#box-actions .mark').click(function(event) {
        event.preventDefault();
        $('#spinner').removeClass('hide');
        mark_to_set = $(this).data('mark');
        if(mark_to_set == 'ignore' || mark_to_set == 'unignore') {
            $('input[name="_method"]').val('delete');
        } else {
            $('input[name="_method"]').val('put');
        }
        $('input[name="mark_to_set"]').val(mark_to_set);
        $('#box').submit();
    });
    $('#box')
        .on('ajax:success', function (e, data, status, xhr) {
            $('#spinner').addClass('hide');
            process_results(data);
        }).on('ajax:error', function (e, data, status, xhr) {
            create_alert('danger', data.responseJSON.message);
        });
    $('#box #message_train_messages .read').each(function(e){
        $(this).find('.collapse').collapse('hide');
    });

    add_tag_magic(".recipient-input");
});