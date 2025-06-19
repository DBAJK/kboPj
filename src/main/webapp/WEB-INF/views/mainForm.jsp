
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
        <c:choose>
            <c:when test="${recordType eq 'Hitter'}">
                <div class="tab-content">
                    <table>
                        <thead>
                        <tr>
                            <th>순위</th><th>선수명</th><th>팀명</th>
                            <th>AVG</th><th>G</th><th>PA</th><th>AB</th>
                            <th>H</th><th>2B</th><th>3B</th><th>HR</th>
                            <th>RBI</th><th>SB</th><th>CS</th>
                            <th>BB</th><th>HBP</th><th>SO</th><th>GDP</th><th>E</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}" >
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamId}</td>
                                <td>${player.avg}</td>
                                <td>${player.g}</td>
                                <td>${player.pa}</td>
                                <td>${player.ab}</td>
                                <td>${player.h}</td>
                                <td>${player.h2}</td>
                                <td>${player.h3}</td>
                                <td>${player.hr}</td>
                                <td>${player.rbi}</td>
                                <td>${player.sb}</td>
                                <td>${player.cs}</td>
                                <td>${player.bb}</td>
                                <td>${player.hbp}</td>
                                <td>${player.so}</td>
                                <td>${player.gdp}</td>
                                <td>${player.e}</td>
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
                            <th>ERA</th><th>G</th><th>CG</th><th>SHO</th>
                            <th>W</th><th>L</th><th>SV</th><th>HLD</th>
                            <th>WPCT</th><th>TBF</th><th>IP</th><th>H</th>
                            <th>HR</th><th>BB</th><th>HBP</th><th>SO</th>
                            <th>R</th><th>ER</th><th>GS</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}">
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamId}</td>
                                <td>${player.era}</td>
                                <td>${player.g}</td>
                                <td>${player.cg}</td>
                                <td>${player.sho}</td>
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
                                <td>${player.gs}</td>
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
                            <th>순위</th><th>선수명</th><th>팀명</th>
                            <th>수비이닝</th><th>KO</th><th>PO</th><th>A</th>
                            <th>DP</th><th>PB</th>
                            <th>도루저지</th><th>도루허용</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}" >
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamId}</td>
                                <td>${player.dIp}</td>
                                <td>${player.pko}</td>
                                <td>${player.po}</td>
                                <td>${player.a}</td>
                                <td>${player.dp}</td>
                                <td>${player.pb}</td>
                                <td>${player.dsb}</td>
                                <td>${player.dcs}</td>
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
                            <th>순위</th><th>선수명</th><th>팀명</th>
                            <th>도루성공</th><th>도루시도</th><th>도루실패</th>
                            <th>성공률</th><th>주루사</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="player" items="${playerList}">
                            <tr>
                                <td>${player.playerRank}</td>
                                <td>${player.name}</td>
                                <td>${player.teamId}</td>
                                <td>${player.sb2}</td>
                                <td>${player.sba}</td>
                                <td>${player.cs2}</td>
                                <td>${player.sbp}</td>
                                <td>${player.oob}</td>
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
