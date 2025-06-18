<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>스코어보드</title>
    <style>
        body {
            font-family: "Malgun Gothic", sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .title {
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }
        
        .breadcrumb {
            color: #666;
            font-size: 12px;
        }
        
        .date-nav {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .date-nav button {
            background: none;
            border: none;
            font-size: 18px;
            cursor: pointer;
            padding: 5px;
        }
        
        .date-nav .date {
            margin: 0 20px;
            font-size: 16px;
            font-weight: bold;
        }
        
        .game-container {
            background: white;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-bottom: 15px;
            overflow: hidden;
        }
        
        .game-header {
            background: #f8f9fa;
            padding: 10px 15px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .game-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .game-time {
            font-weight: bold;
            color: #333;
        }
        
        .team-logos {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .team-logo {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: white;
            font-size: 12px;
        }
        
        .vs {
            font-weight: bold;
            color: #666;
        }
        
        .game-status {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .status-badge {
            background: #007bff;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 11px;
        }
        
        .prediction-section {
            background: #fff3cd;
            padding: 10px 15px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .prediction-title {
            font-weight: bold;
            color: #856404;
        }
        
        .prediction-buttons {
            display: flex;
            gap: 10px;
        }
        
        .predict-btn {
            padding: 5px 15px;
            border: 1px solid #007bff;
            background: white;
            color: #007bff;
            border-radius: 20px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s ease;
        }
        
        .predict-btn:hover {
            background: #007bff;
            color: white;
        }
        
        .predict-btn.selected {
            background: #28a745;
            color: white;
            border-color: #28a745;
        }
        
        .scoreboard {
            overflow-x: auto;
        }
        
        .scoreboard table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }
        
        .scoreboard th, .scoreboard td {
            text-align: center;
            padding: 8px 4px;
            border-right: 1px solid #ddd;
            min-width: 25px;
        }
        
        .scoreboard th {
            background: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        
        .scoreboard .team-name {
            text-align: left;
            font-weight: bold;
            padding-left: 10px;
            background: #f8f9fa;
            width: 60px;
        }
        
        .scoreboard tr:nth-child(even) {
            background: #f9f9f9;
        }
        
        .prediction-stats {
            background: #e7f3ff;
            padding: 8px 15px;
            font-size: 11px;
            color: #0056b3;
            text-align: center;
        }
        
        /* 팀별 색상 */
        .ssg { background: #ff6b6b; }
        .lg { background: #cc0000; }
        .lotte { background: #002266; }
        .kt { background: #000000; }
        .lions { background: #0066cc; }
        .kia { background: #ea002c; }
        .nc { background: #315288; }
        .kiwoom { background: #820024; }
        .doosan { background: #131230; }
        .hanwha { background: #ff6600; }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">스코어보드</div>
        <div class="breadcrumb">홈 > 야구 > 스코어보드</div>
    </div>
    
    <div class="date-nav">
        <button onclick="changeDate(-1)">◀</button>
        <div class="date" id="currentDate">2025.06.10(화)</div>
        <button onclick="changeDate(1)">▶</button>
    </div>
    
    <div class="game-container">
        <div class="game-header">
            <div class="game-info">
                <div class="game-time">잠실 18:30</div>
                <div class="team-logos">
                    <div class="team-logo ssg">SSG</div>
                    <div class="vs">vs</div>
                    <div class="team-logo lg">LG</div>
                </div>
            </div>
            <div class="game-status">
                <div class="status-badge">경기전</div>
                <button onclick="toggleDetails(1)">상세보기</button>
            </div>
        </div>
        
        <div class="prediction-section">
            <div class="prediction-title">🏆 승부예측</div>
            <div class="prediction-buttons">
                <button class="predict-btn" onclick="selectPrediction(1, 'ssg', this)">SSG 승리</button>
                <button class="predict-btn" onclick="selectPrediction(1, 'lg', this)">LG 승리</button>
            </div>
        </div>
        
        <div class="prediction-stats" id="stats1">
            현재 예측: SSG(45%) vs LG(55%) | 총 1,247명 참여
        </div>
        
        <div class="scoreboard">
            <table>
                <thead>
                    <tr>
                        <th>TEAM</th>
                        <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th>
                        <th>R</th><th>H</th><th>E</th><th>B</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="team-name">SSG</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                    <tr>
                        <td class="team-name">LG</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="game-container">
        <div class="game-header">
            <div class="game-info">
                <div class="game-time">수원 18:30</div>
                <div class="team-logos">
                    <div class="team-logo lotte">롯데</div>
                    <div class="vs">vs</div>
                    <div class="team-logo kt">KT</div>
                </div>
            </div>
            <div class="game-status">
                <div class="status-badge">경기전</div>
                <button onclick="toggleDetails(2)">상세보기</button>
            </div>
        </div>
        
        <div class="prediction-section">
            <div class="prediction-title">🏆 승부예측</div>
            <div class="prediction-buttons">
                <button class="predict-btn" onclick="selectPrediction(2, 'lotte', this)">롯데 승리</button>
                <button class="predict-btn" onclick="selectPrediction(2, 'kt', this)">KT 승리</button>
            </div>
        </div>
        
        <div class="prediction-stats" id="stats2">
            현재 예측: 롯데(38%) vs KT(62%) | 총 892명 참여
        </div>
        
        <div class="scoreboard">
            <table>
                <thead>
                    <tr>
                        <th>TEAM</th>
                        <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th>
                        <th>R</th><th>H</th><th>E</th><th>B</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="team-name">롯데</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                    <tr>
                        <td class="team-name">KT</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="game-container">
        <div class="game-header">
            <div class="game-info">
                <div class="game-time">광주 18:30</div>
                <div class="team-logos">
                    <div class="team-logo lions">삼성</div>
                    <div class="vs">vs</div>
                    <div class="team-logo kia">KIA</div>
                </div>
            </div>
            <div class="game-status">
                <div class="status-badge">경기전</div>
                <button onclick="toggleDetails(3)">상세보기</button>
            </div>
        </div>
        
        <div class="prediction-section">
            <div class="prediction-title">🏆 승부예측</div>
            <div class="prediction-buttons">
                <button class="predict-btn" onclick="selectPrediction(3, 'samsung', this)">삼성 승리</button>
                <button class="predict-btn" onclick="selectPrediction(3, 'kia', this)">KIA 승리</button>
            </div>
        </div>
        
        <div class="prediction-stats" id="stats3">
            현재 예측: 삼성(52%) vs KIA(48%) | 총 1,033명 참여
        </div>
        
        <div class="scoreboard">
            <table>
                <thead>
                    <tr>
                        <th>TEAM</th>
                        <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th>
                        <th>R</th><th>H</th><th>E</th><th>B</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="team-name">삼성</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                    <tr>
                        <td class="team-name">KIA</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="game-container">
        <div class="game-header">
            <div class="game-info">
                <div class="game-time">고척 18:30</div>
                <div class="team-logos">
                    <div class="team-logo nc">NC</div>
                    <div class="vs">vs</div>
                    <div class="team-logo kiwoom">키움</div>
                </div>
            </div>
            <div class="game-status">
                <div class="status-badge">경기전</div>
                <button onclick="toggleDetails(4)">상세보기</button>
            </div>
        </div>
        
        <div class="prediction-section">
            <div class="prediction-title">🏆 승부예측</div>
            <div class="prediction-buttons">
                <button class="predict-btn" onclick="selectPrediction(4, 'nc', this)">NC 승리</button>
                <button class="predict-btn" onclick="selectPrediction(4, 'kiwoom', this)">키움 승리</button>
            </div>
        </div>
        
        <div class="prediction-stats" id="stats4">
            현재 예측: NC(43%) vs 키움(57%) | 총 756명 참여
        </div>
        
        <div class="scoreboard">
            <table>
                <thead>
                    <tr>
                        <th>TEAM</th>
                        <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th>
                        <th>R</th><th>H</th><th>E</th><th>B</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="team-name">NC</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                    <tr>
                        <td class="team-name">키움</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="game-container">
        <div class="game-header">
            <div class="game-info">
                <div class="game-time">대전 18:30</div>
                <div class="team-logos">
                    <div class="team-logo doosan">두산</div>
                    <div class="vs">vs</div>
                    <div class="team-logo hanwha">한화</div>
                </div>
            </div>
            <div class="game-status">
                <div class="status-badge">경기전</div>
                <button onclick="toggleDetails(5)">상세보기</button>
            </div>
        </div>
        
        <div class="prediction-section">
            <div class="prediction-title">🏆 승부예측</div>
            <div class="prediction-buttons">
                <button class="predict-btn" onclick="selectPrediction(5, 'doosan', this)">두산 승리</button>
                <button class="predict-btn" onclick="selectPrediction(5, 'hanwha', this)">한화 승리</button>
            </div>
        </div>
        
        <div class="prediction-stats" id="stats5">
            현재 예측: 두산(60%) vs 한화(40%) | 총 1,156명 참여
        </div>
        
        <div class="scoreboard">
            <table>
                <thead>
                    <tr>
                        <th>TEAM</th>
                        <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th>
                        <th>R</th><th>H</th><th>E</th><th>B</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="team-name">두산</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                    <tr>
                        <td class="team-name">한화</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
                        <td>-</td><td>-</td><td>-</td><td>-</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // 사용자 예측 저장
        let userPredictions = {};
        
        function changeDate(direction) {
            // 날짜 변경 로직
            alert(direction > 0 ? '다음 날로 이동' : '이전 날로 이동');
        }
        
        function toggleDetails(gameId) {
            alert('경기 ' + gameId + ' 상세 정보');
        }
        
        function selectPrediction(gameId, team, button) {
            // 같은 게임의 다른 버튼들 선택 해제
            const gameContainer = button.closest('.game-container');
            const allButtons = gameContainer.querySelectorAll('.predict-btn');
            allButtons.forEach(btn => btn.classList.remove('selected'));
            
            // 현재 버튼 선택
            button.classList.add('selected');
            
            // 사용자 예측 저장
            userPredictions[gameId] = team;
            
            // 예측 완료 메시지
            const teamName = button.textContent;
            alert('✅ ' + teamName + ' 예측이 완료되었습니다!');
            
            // 실제 구현시에는 서버로 데이터 전송
            // sendPredictionToServer(gameId, team);
        }
        
        // 서버로 예측 데이터 전송 (실제 구현용)
        function sendPredictionToServer(gameId, team) {
            /*
            JSP에서 실제 구현시 사용할 코드:
            
            fetch('/prediction', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    gameId: gameId,
                    team: team,
                    userId: getCurrentUserId()
                })
            })
            .then(response => response.json())
            .then(data => {
                updatePredictionStats(gameId, data);
            });
            */
        }
        
        // 예측 통계 업데이트
        function updatePredictionStats(gameId, data) {
            const statsElement = document.getElementById('stats' + gameId);
            if (statsElement && data) {
                statsElement.textContent = 
                    `현재 예측: ${data.team1Name}(${data.team1Percent}%) vs ${data.team2Name}(${data.team2Percent}%) | 총 ${data.totalVotes}명 참여`;
            }
        }
        
        // 페이지 로드시 사용자의 기존 예측 복원
        function loadUserPredictions() {
            /*
            JSP에서 실제 구현시:
            
            fetch('/user-predictions')
            .then(response => response.json())
            .then(predictions => {
                Object.keys(predictions).forEach(gameId => {
                    const team = predictions[gameId];
                    const button = document.querySelector(`[onclick*="selectPrediction(${gameId}, '${team}'"]`);
                    if (button) {
                        button.classList.add('selected');
                    }
                });
            });
            */
        }
        
        // 페이지 로드시 실행
        document.addEventListener('DOMContentLoaded', function() {
            loadUserPredictions();
        });
    </script>
</body>
</html>
