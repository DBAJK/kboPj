<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<link href="/resources/css/kboBoard.css" rel="stylesheet" type="text/css">
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<div class="content">
<div class="kboBoard-header">
    <div class="header-title">
        <div class="title">승부예측 - 스코어 보드</div>
    </div>

    <div class="date-nav">
        <button onclick="changeDate(-1)">◀</button>
        <div class="date" id="currentDate"></div>
        <button onclick="changeDate(1)">▶</button>
    </div>
    <div class="scoreboard-container">
    <c:choose>
        <c:when test="${empty games}">
            <div class="no-data">해당 날짜에 경기가 없습니다.</div>
        </c:when>
        <c:otherwise>
            <c:forEach var="game" items="${games}">
                <div class="game-container" data-game-id="${game.game_id}">
                    <div class="game-header">
                        <div class="game-info">
                            <div class="game-time">${game.venue}</div>
                            <div class="game-score">${game.team1Name} (${game.home_score})</div>
                            <div> : </div>
                            <div class="game-score">(${game.away_score}) ${game.team2Name}</div>
                        </div>
                        <c:if test="${not empty game.actual_winner_teamName}">
                            <div class="winner-info">
                                <span class="winner-label">승리팀:</span>
                                <span class="winner-name">${game.actual_winner_teamName}</span>
                            </div>
                        </c:if>
                        <div class="team-logos">
                            <button class="team-logo ${game.team1Class}
                            <c:if test='${not empty game.predicted_team_id and game.predicted_team_id == game.team1Id}'> selected</c:if>"
                                    onclick="selectPrediction(${game.game_id}, '${game.team1Class}', ${game.team1Id},this)"
                                    <c:if test="${not empty game.predicted_team_id and game.predicted_team_id != 0}">disabled</c:if>>
                                    ${game.team1Name}
                            </button>
                            <div class="vs">vs</div>
                            <button class="team-logo ${game.team2Class}
                            <c:if test='${not empty game.predicted_team_id and game.predicted_team_id == game.team2Id}'> selected</c:if>"
                                    onclick="selectPrediction(${game.game_id}, '${game.team2Class}', ${game.team2Id}, this)"
                                    <c:if test="${not empty game.predicted_team_id and game.predicted_team_id != 0}">disabled</c:if>>
                                    ${game.team2Name}
                            </button>
                        </div>
                    </div>
                    <div class="scoreboard">
                        <table>
                            <thead>
                            <tr>
                                <th>TEAM</th>
                                <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th>
                                <th>6</th><th>7</th><th>8</th><th>9</th><th>10</th>
                                <th>11</th><th>12</th><th>R</th><th>H</th><th>E</th><th>B</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td class="team-name">${game.team1Name}</td>
                                <c:forEach var="score" items="${game.team1Scores}">
                                    <td class="score-text">${score}</td>
                                </c:forEach>
                                <c:forEach var="total" items="${game.team1Total}">
                                    <td class="score-total">${total}</td>
                                </c:forEach>
                            </tr>
                            <tr>
                                <td class="team-name">${game.team2Name}</td>
                                <c:forEach var="score" items="${game.team2Scores}">
                                    <td class="score-text">${score}</td>
                                </c:forEach>
                                <c:forEach var="total" items="${game.team2Total}">
                                    <td class="score-total">${total}</td>
                                </c:forEach>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <c:if test="${not empty game.predicted_team_id and game.predicted_team_id != 0}">
                        <div class="prediction-info">
                            <span>내 예측: ${game.predicted_team_name}</span>
                            <c:choose>
                                <c:when test="${not empty game.actual_winner_id and game.actual_winner_id != 0}">
                                    <span>
                                        <c:choose>
                                            <c:when test="${game.predicted_team_id == game.actual_winner_id}">
                                                (win)
                                            </c:when>
                                            <c:otherwise>
                                                (Lose)
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span>(경기 결과 대기중)</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
    </div>
</div>
</div>
<script>
    let userPredictions = {};
    $(document).ready(function() {
        const todayDate = getTodayDateStr();
        const todayKorean = getTodayKoreanStr();
        $('#currentDate').data('date', todayDate).text(todayKorean);
        changeDate(0);
    });

    function selectPrediction(gameId, team, teamId,button) {
        // 같은 게임의 다른 버튼들 선택 해제
        const gameContainer = button.closest('.game-container');
        const allButtons = gameContainer.querySelectorAll('.team-logo');
        allButtons.forEach(btn => btn.classList.remove('selected'));

        button.classList.add('selected');

        userPredictions[gameId] = team;
        // 예측 완료 메시지
        const teamName = button.textContent;
        // 실제 구현시에는 서버로 데이터 전송
        sendPredictionToServer(gameId, team, teamId);
    }

    // 서버로 예측 데이터 전송 (실제 구현용)
    function sendPredictionToServer(gameId, team, teamId) {
        if(confirm(team + "의 승리에 예측 하셨습니다.\n수정 불가능합니다.")){
            $.ajax({
                url: '/service/updatePrediction',
                data: {game_id : gameId, teamID : teamId},
                type: 'POST',
                success: function(response) {
                    console.log("예측 완료.");
                },
                error: function(xhr, status, error) {
                    console.error("포인트 업데이트 실패:", error);
                }
            });
        }else{
            return;
        }
    }

    function loadScoreBoard(dateStr) {
        $.ajax({
            url: '/service/scoreBoard',
            data: { date: dateStr },
            success: function(html) {
                $('.content').html(html); // content 영역만 갱신
                $('#currentDate')
                    .data('date', dateStr)
                    .text(formatDateToKorean(dateStr));
            }
        });
    }


    // 날짜 변경 버튼에 연결
    function changeDate(direction) {
        // 현재 날짜를 가져와서 +1, -1 계산 (예시)
        let currentDate = $('#currentDate').data('date');
        let newDate = calculateNewDate(currentDate, direction);

        loadScoreBoard(newDate);
    }


    function getTodayDateStr() {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        return `${'${yyyy}'}-${'${mm}'}-${'${dd}'}`;
    }

    function getTodayKoreanStr() {
        const today = new Date();
        const week = ['일', '월', '화', '수', '목', '금', '토'];
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        const day = week[today.getDay()];
        return `${'${yyyy}'}-${'${mm}'}-${'${dd}'}(${'${day}'})`;

    }
    function calculateNewDate(currentDateStr, direction) {
        const parts = currentDateStr.split('-');
        const year = parseInt(parts[0], 10);
        const month = parseInt(parts[1], 10) - 1; // 월은 0부터 시작
        const day = parseInt(parts[2], 10);

        const dateObj = new Date(year, month, day);
        dateObj.setDate(dateObj.getDate() + direction);

        const newYear = dateObj.getFullYear();
        const newMonth = String(dateObj.getMonth() + 1).padStart(2, '0');
        const newDay = String(dateObj.getDate()).padStart(2, '0');
        return `${'${newYear}'}-${'${newMonth}'}-${'${newDay}'}`;
    }
    function formatDateToKorean(dateStr) {
        const parts = dateStr.split('-');
        const year = parts[0];
        const month = parts[1];
        const day = parts[2];

        const dateObj = new Date(year, month - 1, day);
        const week = ['일', '월', '화', '수', '목', '금', '토'];
        const dayOfWeek = week[dateObj.getDay()];
        return `${'${year}'}-${'${month}'}-${'${day}'}(${'${dayOfWeek}'})`;
    }

</script>