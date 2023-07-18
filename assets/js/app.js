const app = new Vue({
    el: '#app',
    data: {
        nui:false,
        page: 3,
        players: [],
        isOpen: true,
        level: 100,
        point: 0,
        percentage: 99,
        levels: [],
        leaderboard: [],
        currentReward: [],
        imgPath: "",
    },
    methods: {
        close() {
            this.nui = false
            $.post(`https://jenga_easteregg/exit`, JSON.stringify({}));
        },
    },
})

window.addEventListener('message', function(event) {
    let data = event.data;

    app.levels = [];
    app.leaderboard = [];
    app.currentReward = [];

    if (data.nui == "level"){
        app.nui = true;
        app.page = 2;
        app.level = data.playerData.level;
        app.point = data.playerData.point;
        app.levels = data.config;
        app.imgPath = data.path;
        data.config[Number(data.playerData.level) + 1] != undefined ? app.percentage = (data.playerData.point / data.config[Number(data.playerData.level) + 1].maxPoint) * 100 : app.percentage = 100;
    } else if (data.nui == "leaderboard") {
        app.nui = true;
        app.page = 1;
        app.leaderboard = data.list.sort(function(a, b){return b.point - a.point});
    } else if (data.nui == "getReward") {
        app.isOpen = true;
        app.nui = true;
        app.page = 3;
        app.currentReward = data.reward;
        app.imgPath = data.path;
        setTimeout(Stop, 1000);
    }

})

document.onkeyup = function(data) {
    if (data.which == 8) { // Back Key
        app.page = 1;
    } else if (data.which == 27) { // Escape Key
        app.close();
    }
};

function Stop() {
    let element = document.getElementById("egg");

    element.style.opacity = '0';
    setTimeout(() => {
        element.style.animationPlayState = 'paused';
        element.style.opacity = '1';
        app.isOpen = false;
    }, 2000);
}

// setTimeout(Stop, 1);