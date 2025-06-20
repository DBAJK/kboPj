
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link href="/resources/css/main.css" rel="stylesheet" type="text/css">
<style>
    th {
        padding: 14px 10px;
        text-align: center;
        font-weight: 600;
        color: #495057;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border: 1px solid #dee2e6;
        font-size: 13px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        position: sticky;
        top: 0;
        z-index: 10;
    }

    /* 선수명, 팀명 헤더 강조 */
    th:nth-child(2), th:nth-child(3) {
        background: linear-gradient(135deg, #e9ecef 0%, #f8f9fa 100%);
        font-weight: 700;
        color: #343a40;
    }

    /* AVG 헤더 강조 */
    th:nth-child(4) {
        background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
        color: #155724;
        font-weight: 700;
    }

    /* 테이블 데이터 셀 스타일 */
    td {
        padding: 12px 10px;
        text-align: center;
        border: 1px solid #dee2e6;
        font-size: 14px;
        transition: all 0.2s ease;
    }

    /* 선수명 셀 스타일 */
    td:nth-child(2) {
        font-weight: 600;
        color: #2c3e50;
        text-align: left;
        padding-left: 15px;
        background: rgba(102, 126, 234, 0.03);
    }

    /* 팀명 셀 스타일 */
    td:nth-child(3) {
        font-weight: 500;
        color: #6c757d;
        background: rgba(102, 126, 234, 0.02);
    }

    td:nth-child(4) {
        font-weight: 700;
        color: #28a745;
        background: rgba(40, 167, 69, 0.05);
    }

    /* 행 호버 효과 */
    tbody tr:hover td {
        background: rgba(102, 126, 234, 0.1) !important;
        transform: scale(1.01);
    }

    /* 반응형 */
    @media (max-width: 768px) {
        th, td {
            padding: 8px 6px;
            font-size: 12px;
        }

        td:nth-child(2) {
            padding-left: 10px;
        }
    }
</style>
<div class="main-content">
    <div class="grid">
    <div class="main-title">기록실</div>
    <div class="tab-container">
        <ul class="tab">
            <li data-tab="Hitter">
                <a href="#" onclick="fetchPlayerStats('Hitter')">타자</a>
            </li>
            <li data-tab="Pitcher">
                <a href="#" onclick="fetchPlayerStats('Pitcher')">투수</a>
            </li>
            <li data-tab="Defense">
                <a href="#" onclick="fetchPlayerStats('Defense')">수비</a>
            </li>
            <li data-tab="Runner">
                <a href="#" onclick="fetchPlayerStats('Runner')">주루</a>
            </li>
        </ul>
        <div class="tab-area"></div>
        <c:choose>
            <c:when test="${recordType eq 'Hitter'}">
                <div class="tab-content">
                    <table>
                        <thead>
                        <tr>
                            <th>순위</th><th>선수명</th><th>팀명</th>
                            <th>타율</th><th>경기수</th><th>타석</th><th>타수</th><th>득점</th>
                            <th>안타</th><th>2루타</th><th>3루타</th><th>홈런</th>
                            <th>루타</th><th>타점</th><th>희생번트</th><th>희생플라이</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}">
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamName}</td>
                                <td>${player.avg}</td>
                                <td>${player.g}</td>
                                <td>${player.pa}</td>
                                <td>${player.ab}</td>
                                <td>${player.r}</td>
                                <td>${player.h}</td>
                                <td>${player.h2}</td>
                                <td>${player.h3}</td>
                                <td>${player.hr}</td>
                                <td>${player.tb}</td>
                                <td>${player.rbi}</td>
                                <td>${player.sac}</td>
                                <td>${player.sf}</td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:when test="${recordType eq 'Pitcher'}">
                <div class="tab-content">
                    <table>
                        <thead>
                        <tr>
                            <th>순위</th><th>선수명</th><th>팀명</th>
                            <th>ERA</th><th>경기</th><th>승리</th><th>패배</th>
                            <th>세이브</th><th>홀드</th><th>승률</th><th>이닝</th>
                            <th>피안타</th><th>홈런</th><th>볼넷</th><th>사구</th>
                            <th>삼진</th><th>실점</th><th>자책점</th><th>이닝당 출루허용률</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}">
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamName}</td>
                                <td>${player.era}</td>
                                <td>${player.w}</td>
                                <td>${player.l}</td>
                                <td>${player.sv}</td>
                                <td>${player.hld}</td>
                                <td>${player.wpct}</td>
                                <td>${player.tbf}</td>
                                <td>${player.ip}</td>
                                <td>${player.ph}</td>
                                <td>${player.phr}</td>
                                <td>${player.pbb}</td>
                                <td>${player.phbp}</td>
                                <td>${player.pso}</td>
                                <td>${player.pr}</td>
                                <td>${player.per}</td>
                                <td>${player.whip}</td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:when test="${recordType eq 'Defense'}">
                <div class="tab-content">
                    <table>
                        <thead>
                        <tr>
                            <th>순위</th><th>선수명</th><th>팀명</th><th>수비율</th>
                            <th>포지션</th><th>경기</th><th>선발경기</th><th>수비이닝</th>
                            <th>실책</th><th>견제사</th><th>풋아웃</th><th>어시스트</th>
                            <th>병살</th><th>포일</th><th>도루허용</th>
                            <th>도루실패</th><th>도루저지율</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}">
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamName}</td>
                                <td>${player.fpct}</td>
                                <td>${player.position}</td>
                                <td>${player.g}</td>
                                <td>${player.gs}</td>
                                <td>${player.dip}</td>
                                <td>${player.e}</td>
                                <td>${player.pko}</td>
                                <td>${player.po}</td>
                                <td>${player.a}</td>
                                <td>${player.dp}</td>
                                <td>${player.pb}</td>
                                <td>${player.dsb}</td>
                                <td>${player.dcs}</td>
                                <td>${player.csRt != null ? player.csRt : '-'}</td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:when test="${recordType eq 'Runner'}">
                <div class="tab-content">
                    <table>
                        <thead>
                        <tr>
                            <th>순위</th><th>선수명</th><th>팀명</th><th>도루시도</th>
                            <th>경기</th><th>도루성공</th><th>도루실패</th>
                            <th>성공률</th><th>주루사</th><th>견제사</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}">
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamName}</td>
                                <td>${player.sba}</td>
                                <td>${player.g}</td>
                                <td>${player.sb2}</td>
                                <td>${player.cs2}</td>
                                <td>${player.sbp}</td>
                                <td>${player.oob}</td>
                                <td>${player.pko}</td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="tab-content">선수 데이터가 없습니다.</div>
                <div>${recordType}</div>
            </c:otherwise>
        </c:choose>
    </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        fetchPlayerStats('Hitter');
    });

    function fetchPlayerStats(recordType) {
        // 모든 탭에서 'on' 제거
        document.querySelectorAll('.tab li').forEach(li => {
            li.classList.remove('on');
        });

        // 현재 탭에만 'on' 추가
        const activeTab = document.querySelector(`.tab li[data-tab="${'${recordType}'}"]`);
        if (activeTab) {
            activeTab.classList.add('on');
        }

        $.ajax({
            url: '/service/playerStats',
            data: { recordType: recordType },
            success: function (html) {
                // $('.grid').html(html); // content 영역만 갱신
                const temp = document.createElement('div');
                temp.innerHTML = html;

                // 예: 서버가 보낸 html 중 <div class="tab-content">만 추출
                const newContent = temp.querySelector('.tab-content');
                if (newContent) {
                    $('.tab-content').html(newContent.innerHTML); // 내부 내용만 교체
                } else {
                    console.warn("대상 div를 찾을 수 없습니다.");
                }

            },
            error: function (xhr, status, error) {
                console.error("조회 실패:", error);
            }
        });
    }
</script>
