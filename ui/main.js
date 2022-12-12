const search_fade_animation = 400
const search_type_delay = 550
let Buttons = [];
let Button = [];

const OpenMenu = (data) => {
    DrawButtons(data)
}

const CreateOverlay = (data) => {
    let ele = document.querySelector('.info')
    // @swkeep: changed context to subheader as i always do :)
    let context = data.subheader ? data.subheader : ""
    let footer = data.footer ? data.footer : ""
    let element = $(`
        <div class="info">
            <div class="column">
                <div class="row">
                    ${data.icons['header'] ? `<div class="icon-o"> <i class="${data.icons['header']}"></i> </div>` : ""} 
                    <div class="header"> ` + data.header + `</div>
                </div>
                <div class="row">
                    ${data.icons['subheader'] ? `<div class="icon-o"> <i class="${data.icons['subheader']}"></i> </div>` : ""} 
                    <div class="context">` + context + `</div>
                </div>

                <div class="row">
                    ${data.icons['footer'] ? `<div class="icon-o"> <i class="${data.icons['footer']}"></i> </div>` : ""} 
                    <div class="footer"> ` + footer + `</div>
                </div>
            </div>
        </div>
        `
    );

    if (ele != null) {
        $('div.info').replaceWith(element);

    } else {
        $('#infos').append(element);
    }
}

const CloseOverlay = () => {
    let element = $(``);
    $('div.info').replaceWith(element);
};

const CloseMenu = () => {
    // remove search bar
    $(".searchbar").remove();
    $(".searchbarDisabled").remove();
    // remove buttons
    $(".button").remove();
    $(".buttonDisabled").remove();
    // remove stteper
    $(".stepper-container").remove();
    $(".stepper").remove();
    // remove pin
    $(".pin-container").remove();
    // remove hover
    $("imageHover").remove();

    Buttons = [];
    Button = [];
};

function btn_next(data, i) {
    let element = $(`
            <div class="${data[i].disabled ? "stepperDisabled next-radius" : "stepper next-radius"}" id=${i} ${data[i].style ? `style="${data[i].style}"` : ""}>
                <div class="icon" id=${i}> <i class="fa-regular fa-circle-right" id=${i}></i> </div>

                <div className="column">
                    <div class="header" id=${i}>Next</div>
                </div>
            </div>
            `
    );
    $('.stepper-container').append(element);
    Buttons[i] = element
    Button[i] = data[i]
}

function btn_pervious(data, i) {
    let element = $(`
            <div class ="stepper-container">
                <div class="${data[i].disabled ? "stepperDisabled pervious-radius" : "stepper pervious-radius"}" id=${i}>
                    <div class="icon" id=${i}> <i class="fa-regular fa-circle-left" id=${i}></i> </div>

                    <div className="column">
                        <div class="header" id=${i}>Pervious</div>
                    </div>
                </div>
            </div>`
    );
    $('#buttons').append(element);
    Buttons[i] = element
    Button[i] = data[i]
}

function contorl_bar() {
    if (!document.querySelectorAll('div.pin-container').length > 0) {
        let element = $(`<div class ="pin-container"></div>`);
        $('#buttons').append(element);
    }
}

function btn_pin(data, i) {
    contorl_bar()
    let element = $(`
            <div class="pin" id=${i} ${data[i].style ? `style="${data[i].style}"` : ""}>
                <div class="icon" id=${i}> <i class="${data[i].icon}" id=${i}></i> </div>
                <div class="header" id=${i}>${data[i].header}</div>
            </div>`
    );
    $('.pin-container').append(element);
    Buttons[i] = element
    Button[i] = data[i]
}

function btn_leave(data, i) {
    contorl_bar()
    let element = $(`
            <div class="leave" id=${i} ${data[i].style ? `style="${data[i].style}"` : ""}>
                <div class="icon" id=${i}> <i class="fa-solid fa-circle-xmark" id=${i}></i> </div>
                <div class="header" id=${i}>Leave</div>
            </div>`
    );
    $('.pin-container').append(element);
    Buttons[i] = element
    Button[i] = data[i]
}

function bar_search(data, i) {
    let element = $(`
            <div class="${data[i].disabled ? "searchbarDisabled" : "searchbar"} ${data[i].spacer ? "is-spacer" : ""}" id=${i} ${data[i].style ? `style="${data[i].style}"` : ""}>
                <div class="icon"> <i class="fa-solid fa-magnifying-glass" id=${i}></i> </div>
                <input type="text" id="${data[i].disabled ? "searchDisabled" : "search"}" ${data[i].disabled ? "disabled" : ""} placeholder="Search ...">
            </div>
            `
    );
    $('#buttons').append(element);
    Buttons[i] = element
    Button[i] = data[i]
}

function _search(Button, i, type, searchText) {
    const _string = Button[i][type].replace(/\s/g, '').toLowerCase()
    searchText = searchText.replace(/\s/g, '').toLowerCase()
    if (_string.indexOf(searchText) != -1) {
        Buttons[i].fadeIn(search_fade_animation, 'swing')
    } else {
        Buttons[i].fadeOut(search_fade_animation, 'swing')
    }
}

function delay(callback, ms) {
    var timer = 0;
    return function () {
        var context = this, args = arguments;
        clearTimeout(timer);
        timer = setTimeout(function () {
            callback.apply(context, args);
        }, ms || 0);
    };
}

$('#container').on('input', '#search', delay(function () {
    let searchText = this.value;
    if (searchText == "") {
        for (let i = 1; i < Buttons.length; i++) {
            // if buttons are not searchable don't use fade animation
            if (Button[i].searchable != true) {
                Buttons[i].show()
            } else {
                Buttons[i].fadeIn(search_fade_animation, 'swing')
            }
        }
        return
    }
    for (let i = 1; i < Button.length; i++) {
        if (Button[i].searchable != true) {
            Buttons[i].show()
        } else {
            if (Button[i].header) {
                _search(Button, i, 'header', searchText)
            } else if (Button[i].subheader) {
                _search(Button, i, 'subheader', searchText)
            } else if (Button[i].footer) {
                _search(Button, i, 'footer', searchText)
            }
        }
    }
}, search_type_delay));

const DrawButtons = (data) => {
    for (let i = 0; i < data.length; i++) {
        if (data[i].hide) {
            // hide element
            continue
        }

        if (data[i].next) {
            btn_next(data, i)
        } else if (data[i].pervious) {
            btn_pervious(data, i)
        } else if (data[i].search) {
            bar_search(data, i)
        } else if (data[i].leave) {
            btn_leave(data, i)
        } else if (data[i].pin) {
            btn_pin(data, i)
        } else {
            // @swkeep: changed context to subheader as i always do :)
            let context = data[i].subheader ? data[i].subheader : ""
            let footer = data[i].footer ? data[i].footer : ""
            let element = $(`
            <div class="${data[i].disabled ? "buttonDisabled" : "button"} ${data[i].is_header ? "is-header" : ""} ${data[i].spacer ? "is-spacer" : ""}" id=${i} ${data[i].style ? `style="${data[i].style}"` : ""}>
            <!-- @swkeep: added back/leave/icon -->
            ${data[i].back && !data[i].disabled ? `<div class="icon" id=${i}> <i class="fa-solid fa-angle-left" id=${i}></i> </div>` : ""}
            ${data[i].leave && !data[i].disabled && !data[i].back ? `<div class="icon"> <i class="fa-solid fa-circle-xmark" id=${i}></i> </div>` : ""}
            ${data[i].icon ? `<div class="icon" id=${i}> <i class="${data[i].icon}" id=${i}></i> </div>` : ""}

            <!-- @swkeep: added column to support icon -->
            <div class="column">
                <div class="header" id=${i}>${data[i].header}</div>
                <div class="context" id=${i}>${context}</div>
                <div class="footer" id=${i}>${footer}</div>
                <!-- @swkeep: changed subMenu to submenu :) -->
                ${data[i].submenu && !data[i].disabled ? `<svg class="submenuicon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path d="M5 3l3.057-3 11.943 12-11.943 12-3.057-3 9-9z"/></svg>` : ""}
                </div>
            </div>`
            );
            $('#buttons').append(element);
            Buttons[i] = element
            Button[i] = data[i]
        }
    }
};

$(document).click(function (event) {
    let $target = $(event.target);
    if (($target.closest('.leave').length && $('.leave').is(":visible")) || ($target.closest('.pin').length && $('.pin').is(":visible")) || ($target.closest('.stepper').length && $('.stepper').is(":visible")) || ($target.closest('.button').length && $('.button').is(":visible"))) {
        let id = event.target.id;
        if (Button[id]) {
            if (Button[id].disabled || false) return;
            // <!-- @swkeep: support for no args actions -->
            if (Button[id].is_header || false) return;

            if (!Button[id].event && !Button[id].action && !Button[id].leave && !Button[id].args) {
                console.warn('WARNING: No event, action or args to perform!');
                return;
            }
            PostData(id)
            document.getElementById('imageHover').style.display = 'none';
        }
    }
})

const PostData = (id) => {
    $.post(`https://${GetParentResourceName()}/dataPost`, JSON.stringify({ id: id }))
}

const CancelMenu = () => {
    $.post(`https://${GetParentResourceName()}/cancel`)
}

window.addEventListener("message", (evt) => {
    const data = evt.data
    const info = data.data
    const action = data.action
    switch (action) {
        case "OPEN_MENU":
            return OpenMenu(info);
        case "OPEN_OVERLAY":
            return CreateOverlay(info);
        case 'CLOSE_OVERLAY':
            return CloseOverlay()
        case "CLOSE_MENU":
            return CloseMenu();
        case "CANCEL_MENU":
            return CancelMenu();
        default:
            return;
    }
})

window.addEventListener("keyup", (ev) => {
    if (ev.code === 'Escape') {
        CancelMenu();
        document.getElementById('imageHover').style.display = 'none';
    }
})

window.addEventListener('mousemove', (event) => {
    let $target = $(event.target);
    if ($target.closest('.button:hover').length && $('.button').is(":visible")) {
        let id = event.target.id;
        if (!Button[id]) return
        if (Button[id].image) {
            $("#imageHover").fadeIn(250, 'swing');
            document.getElementById('image').src = Button[id].image;
            document.getElementById('imageHover').style.display = 'block';
        }
    }
    else {
        document.getElementById('imageHover').style.display = 'none';
    }
})