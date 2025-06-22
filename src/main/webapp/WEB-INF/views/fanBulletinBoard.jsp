<%--
  Created by IntelliJ IDEA.
  User: jgkim
  Date: 2025-06-12
  Time: 오후 10:36
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.pj.kboPj.vo.KboPjVO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link href="/resources/css/boardStyle.css" rel="stylesheet" type="text/css">

<script>
    var isRowAdded = false; // 여기서만 선언 (let/const 말고 var로 선언해도 안전)
</script>

<%
    List<KboPjVO> boardList = (List<KboPjVO>) request.getAttribute("boardList");
    int totalCount = (request.getAttribute("totalCount") != null) ? (Integer) request.getAttribute("totalCount") : 0;
    String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
%>

<link href="/resources/css/boardStyle.css" rel="stylesheet" type="text/css">

<div class="body-container">
    <div class="board-header">
        <h1 class="h1-header">
            <span>
              <%
                  String userTeamLogo = (String) session.getAttribute("userTeamLogo");
                  if (userTeamLogo != null && !userTeamLogo.isEmpty()) {
              %>
                <img src="<%= userTeamLogo %>" style="width:100px; height:100px;" />
              <%
                  }
              %>
            </span>
            팬 게시판
        </h1>
    </div>

    <div class="stats">
        총 게시글: <%= totalCount %>개
    </div>

    <div class="board-controls">
        <div class="search-box">
            <input type="text" name="keyword" id="keyword" placeholder="제목 또는 작성자 검색..." value="<%= keyword %>">
            <button type="button" onclick="getBoardAll()" class="btn btn-primary">검색</button>
        </div>
        <%
            if (userTeamLogo != null && !userTeamLogo.isEmpty()) {
        %>
        <button id="btnNew" onclick="addRow();" class="btn btn-success">새 글 작성</button>
        <%
            }
        %>
    </div>
    <div class="board-contents">
    <table class="board-table">
        <thead>
        <tr>
            <th style="width: 80px;">번호</th>
            <th style="width: auto;">제목</th>
            <th style="width: 120px;">작성자</th>
            <th style="width: 120px;">작성일</th>
            <th style="width: 80px;">조회수</th>
            <%
                Object teamIdObj = session.getAttribute("userTeamId");
                int userTeamId = 0; // 기본값 설정

                if (teamIdObj != null) {
                    try {
                        // 정수 변환 시도 (문자열/정수 모두 처리)
                        userTeamId = Integer.parseInt(teamIdObj.toString());
                    } catch (NumberFormatException e) {
                        // 오류 발생 시 기본값 유지
                    }
                }
                if (userTeamId > 0) {
            %>
            <th style="width: 200px;">-</th>
            <%
                }
            %>
        </tr>
        </thead>
        <tbody id="boardListContainer">
        <%
            if (boardList == null || boardList.isEmpty()) {
        %>
        <tr>
            <td colspan="5" class="no-data">아직 작성된 게시글이 없습니다.<br>첫 번째 글을 작성해보세요!</td>
        </tr>
        <%
        } else {
            int boardNo;
            for (int i = 0; i < boardList.size(); i++) {
                KboPjVO board = boardList.get(i);
                boardNo = totalCount - i;
        %>
        <tr>
            <td><%= boardNo %></td>
            <td class="title"><%= board.getBoardTitle() %></td>
            <td class="author"><%= board.getUserName() %></td>
            <td class="date"><%= board.getReg_dt() != null && board.getReg_dt().length() >= 10 ? board.getReg_dt().substring(5, 10) : "" %></td>
            <td class="views"><%= board.getView_cnt() %></td>
            <%
                String loginUserId = (String) session.getAttribute("userId");
                if (loginUserId != null && loginUserId.equals(board.getUserId())) {
            %>
            <td class="bntArea">
                <button data-board="<%= board.getBoardId() %>" id="editBtn" data-action="edit" class="btn btn-sm btn-warning" onclick="editRow(this)">수정</button>
                <button data-board="<%= board.getBoardId() %>" id="delBtn" class="btn btn-sm btn-danger" onclick="delRow(this)">삭제</button>
            </td>
            <%
                }
            %>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
    </div>
</div>

<script>
    $(document).ready(function () {

        $("#keyword").on("keypress", function (e) {
            if (e.which === 13) { // 13 = Enter key
                e.preventDefault();
                getBoardAll();
            }
        });
        getBoardAll();
    });

    function getBoardAll() {
        const keyword = $("#keyword").val();
        $.ajax({
            url: '/service/fanBulletinBoard',
            data: { keyword: keyword },
            success: function (html) {
                $('.body-container').html(html); // content 영역만 갱신
            },
            error: function (xhr, status, error) {
                console.error("조회 실패:", error);
            }
        });
    }

    function addRow() {
        if (isRowAdded) return; // 중복 추가 방지

        const tableBody = document.getElementById("boardListContainer");

        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        const todayStr = `${'${yyyy}'}-${'${mm}'}-${'${dd}'}`;

        const writerName = "<%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "" %>";

        const newRow = document.createElement("tr");
        newRow.setAttribute("id", "newPostRow");
        newRow.innerHTML = `
            <td>신규</td>
            <td><input type="text" id="newTitle" class="form-control" placeholder="제목 입력" /></td>
            <td><input type="text" id="newAuthor" class="form-control" value="${'${writerName}'}" readonly /></td>
            <td><input type="date" id="newDate" class="form-control" value="${'${todayStr}'}" readonly /></td>
            <td>0</td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="submitNewPost()">등록</button>
                <button class="btn btn-sm btn-secondary" onclick="cancelNewPost()">취소</button>
            </td>
        `;

        tableBody.prepend(newRow);
        isRowAdded = true;
    }

    function cancelNewPost() {
        const row = document.getElementById("newPostRow");
        if (row) {
            row.remove();
            isRowAdded = false;
        }
    }

    function submitNewPost() {
        const title = document.getElementById("newTitle").value.trim();
        const author = document.getElementById("newAuthor").value.trim();
        const regDate = document.getElementById("newDate").value;

        if (!title) {
            alert("게시글 항목을 입력해주세요.");
            return;
        }

        $.ajax({
            url: '/service/insertBoard',
            type: 'POST',
            data: {
                boardTitle: title,
                userName: author,
                reg_dt: regDate
            },
            success: function () {
                alert("게시글이 등록되었습니다.");
                getBoardAll(); // 게시글 새로 불러오기
                isRowAdded = false;
            },
            error: function (xhr) {
                console.error("등록 실패:", xhr.responseText);
                alert("등록 중 오류가 발생했습니다.");
            }
        });
    }

    function delRow(btn) {
        const boardId = $(btn).data('board');

        if (!confirm("정말 삭제하시겠습니까?")) return;

        $.ajax({
            url: '/service/deleteBoard',
            type: 'POST',
            data: { boardId: boardId },
            success: function (res) {
                alert("삭제되었습니다.");
                getBoardAll();  // 목록 새로고침
            },
            error: function (xhr, status, error) {
                console.error("삭제 실패:", error);
                alert("삭제 중 오류가 발생했습니다.");
            }
        });
    }

    function editRow(btn) {
        const $row = $(btn).closest("tr");
        if ($row.length === 0) return;

        const $titleTd = $row.find("td.title");
        if ($titleTd.length === 0) return;

        const originalTitle = $titleTd.text().trim();
        const boardId = $(btn).data("board");

        // 이미 수정 중이면 무시
        if ($titleTd.find("input").length > 0) return;

        // 제목을 input 필드로 전환
        $titleTd.html(`<input type="text" class="form-control" value="${'${originalTitle}'}" />`);

        // 버튼 영역 덮어쓰기
        const $btnTd = $row.find("td.bntArea");
        // 버튼 생성 예시
        $btnTd.html(`
            <button class="btn btn-sm btn-success" onclick="saveRow(this)" data-board="${'${boardId}'}">저장</button>
        `);
    }

    function cancelEdit(btn, originalTitle) {
        const $row = $(btn).closest("tr");
        $row.find(".title input").val(originalTitle);
    }

    function saveRow(btn) {
        const $row = $(btn).closest("tr");
        const boardId = $(btn).data("board");
        const $input = $row.find(".title input");
        const updatedTitle = $input.val().trim();
        if (!updatedTitle) {
            alert("제목을 입력하세요.");
            return;
        }

        $.ajax({
            url: "/service/updateBoard",
            type: "POST",
            data: {
                boardId: boardId,
                boardTitle: updatedTitle
            },
            success: function() {
                alert("수정 완료");
                getBoardAll(); // 목록 다시 불러오기
            },
            error: function(xhr) {
                console.error("수정 실패:", xhr.responseText);
                alert("수정 실패");
            }
        });
    }

</script>