

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

$(document).ready(function(){

    $('.night_train_conversation input[type="checkbox"]').change(function(event) {
        if (event.target.checked) {
            //Checkbox has been checked
            $(this).parents('.night_train_conversation').addClass('selected');
        } else {
            //Checkbox has been unchecked
            $(this).parents('.night_train_conversation').removeClass('selected');
        }
    });
    $('#check_all').change(function(event) {
        if (event.target.checked) {
            set_and_change( '.night_train_conversation input[type="checkbox"]', true);
        } else {
            set_and_change( '.night_train_conversation input[type="checkbox"]', false);
        }
    });
    $('#night_train_actions .check').click(function(event) {
        event.preventDefault();
        selector = $(this).data('selector');
        set_and_change( '.night_train_conversation input[type="checkbox"]', false);
        if(selector == '.night_train_conversation') {
            $('#check_all').prop('checked', true);
        } else {
            $('#check_all').prop('checked', false);
        }
        if(selector != '') {
            set_and_change( selector + ' input[type="checkbox"]', true);
        }
    });
    $('#night_train_actions .mark').click(function(event) {
        $('#spinner').removeClass('hide');
        event.preventDefault();
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
            if(typeof data.results === 'undefined') {
                create_alert('warning', data.message);
            } else {
                create_alert('info', data.message);
                for(var key in data.results) {
                    selector = '#' + key;
                    set_and_change(selector + ' input[type="checkbox"]', false);
                    flicker(selector, 3);
                }
            }
        }).on('ajax:error', function (e, data, status, xhr) {
            create_alert('danger', data.responseJSON.message);
        });
});