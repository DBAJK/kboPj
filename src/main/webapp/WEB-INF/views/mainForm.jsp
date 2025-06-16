
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
table {
    border-collapse: collapse;
    width: 100%;
}
th, td {
    padding: 8px;
    text-align: center;
    border: 1px solid #ddd;
}
th {
    background-color: #f0f0f0;
}
</style>
<div>
<h2>기록실</h2>
<div>
    <ul class="tab">
        <li class="on"> <a href="/Record/Player/HitterBasic/Basic1.aspx">타자</a></li>
        <li> <a href="/Record/Player/PitcherBasic/Basic1.aspx">투수</a></li>
        <li> <a href="/Record/Player/Defense/Basic.aspx">수비</a></li>
        <li class="last"> <a href="/Record/Player/Runner/Basic.aspx">주루</a></li>
    </ul>
</div>
<table>
    <thead>
        <tr>
            <th>순위</th>
            <th>선수명</th>
            <th>팀명</th>
            <th>AVG</th>
            <th>G</th>
            <th>PA</th>
            <th>AB</th>
            <th>R</th>
            <th>H</th>
            <th>2B</th>
            <th>3B</th>
            <th>HR</th>
            <th>TB</th>
            <th>RBI</th>
            <th>SAC</th>
            <th>SF</th>
        </tr>
    </thead>
    <tbody id="playerTableBody"></tbody>
</table>
</div>

<script>
    $(document).ready(function () {
        // 페이지 로딩 시 데이터 불러오기
        fetchPlayerStats("Hitter");  // 초기값: Hitter

        // 탭 또는 드롭다운 변경 시
        $("#recordTypeSelect").change(function () {
            let selectedType = $(this).val();
            fetchPlayerStats(selectedType);
        });

        function fetchPlayerStats(recordType) {
            $.ajax({
                url: "/playerStats", // 컨트롤러 매핑 경로
                type: "GET",
                data: { recordType: recordType },
                dataType: "json",
                success: function (data) {
                    renderTable(data);
                },
                error: function (xhr, status, error) {
                    console.error("조회 실패:", error);
                }
            });
        }

        function renderTable(data) {
            const $tbody = $("#playerTableBody");
            $tbody.empty();

            if (!data || data.length === 0) {
                $tbody.append("<tr><td colspan='12'>데이터가 없습니다.</td></tr>");
                return;
            }

            data.forEach(function (player, index) {
                const row = `
                <tr>
                    <td>${index + 1}</td>
                    <td>${player.name}</td>
                    <td>${player.team}</td>
                    <td>${player.avg || "-"}</td>
                    <td>${player.paCn || "-"}</td>
                    <td>${player.abCn || "-"}</td>
                    <td>${player.runCn || "-"}</td>
                    <td>${player.hitCn || "-"}</td>
                    <td>${player.hrCn || "-"}</td>
                    <td>${player.rbiCn || "-"}</td>
                </tr>
            `;
                $tbody.append(row);
            });
        }
    });
</script>
