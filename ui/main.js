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
    $(".button").remove();
    $(".buttonDisabled").remove();
    Buttons = [];
    Button = [];
};

const DrawButtons = (data) => {
    for (let i = 0; i < data.length; i++) {
        if (data[i].hide) {
            // hide element
            continue
        }
        // @swkeep: changed context to subheader as i always do :)
        let context = data[i].subheader ? data[i].subheader : ""
        let footer = data[i].footer ? data[i].footer : ""
        let element = $(`
            <div class="${data[i].disabled ? "buttonDisabled" : "button"} ${data[i].is_header ? "is-header" : ""}" id=` + i + `>
            <!-- @swkeep: added back/leave/icon -->
            ${data[i].back && !data[i].disabled ? `<div class="icon"> <i class="fa-solid fa-angle-left"></i> </div>` : ""}
            ${data[i].leave && !data[i].disabled && !data[i].back ? `<div class="icon"> <i class="fa-solid fa-circle-xmark"></i> </div>` : ""}
            ${data[i].icon ? `<div class="icon"> <i class="${data[i].icon}"></i> </div>` : ""}
            <!-- @swkeep: added column to support icon -->
            <div className="column">
                <div class="header" id=` + i + `>` + data[i].header + `</div>
                <div class="context" id=` + i + `>` + context + `</div>
                <div class="footer" id=` + i + `>` + footer + `</div>
                <!-- @swkeep: changed subMenu to submenu :) -->
                ${data[i].submenu && !data[i].disabled ? `<svg class="submenuicon" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path d="M5 3l3.057-3 11.943 12-11.943 12-3.057-3 9-9z"/></svg>` : ""}
                </div>
            </div>`
        );
        $('#buttons').append(element);
        Buttons[i] = element
        Button[i] = data[i]
    }
};

$(document).click(function (event) {
    let $target = $(event.target);
    if ($target.closest('.button').length && $('.button').is(":visible")) {
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
            document.getElementById('image').src = Button[id].image;
            document.getElementById('imageHover').style.display = 'block';
        }
    }
    else {
        document.getElementById('imageHover').style.display = 'none';
    }
})