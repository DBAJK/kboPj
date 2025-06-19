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
<link href="/resources/css/boardStyle.css" rel="stylesheet" type="text/css">
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>

<%
    List<KboPjVO> boardList = (List<KboPjVO>) request.getAttribute("boardList");
    int totalCount = (request.getAttribute("totalCount") != null) ? (Integer) request.getAttribute("totalCount") : 0;
    String keyword = request.getParameter("keyword") != null ? request.getParameter("keyword") : "";
    int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
    int itemsPerPage = 10;
    int totalPages = (int) Math.ceil((double) totalCount / itemsPerPage);
%>


<link href="/resources/css/boardStyle.css" rel="stylesheet" type="text/css">

<div class="body-head-container">
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
            총 게시글: <strong><%= totalCount %></strong>개
        </div>

        <div class="board-controls">
            <div class="search-box">
                <form method="get" action="board-list.jsp" style="display: flex; gap: 10px;">
                    <input type="text" name="keyword" placeholder="제목 또는 작성자 검색..." value="<%= keyword %>">
                    <button type="submit" class="btn btn-primary">검색</button>
                </form>
            </div>
            <a href="board-dtl.jsp?mode=write" class="btn btn-success">새 글 작성</a>
        </div>

        <table class="board-table">
            <thead>
            <tr>
                <th style="width: 80px;">번호</th>
                <th style="width: auto;">제목</th>
                <th style="width: 120px;">작성자</th>
                <th style="width: 120px;">작성일</th>
                <th style="width: 80px;">조회수</th>
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
                    boardNo = totalCount - ((currentPage - 1) * itemsPerPage + i);
            %>
            <tr>
                <td><%= boardNo %></td>
                <td class="title"><%= board.getBoardTitle() %></td>
                <td class="author"><%= board.getUserName() %></td>
                <td class="date"><%= board.getReg_dt() != null && board.getReg_dt().length() >= 10 ? board.getReg_dt().substring(5, 10) : "" %></td>
                <td class="views"><%= board.getView_cnt() %></td>
            </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>

        <div id="paginationContainer" class="pagination-container">
            <%
                if (totalPages > 1) {
                    if (currentPage  > 1) {
            %>
            <a href="board-list.jsp?page=<%= (currentPage  - 1) %>&keyword=<%= keyword %>" class="page-btn">이전</a>
            <%
                }
                for (int i = 1; i <= totalPages; i++) {
            %>
            <a href="board-list.jsp?page=<%= i %>&keyword=<%= keyword %>" class="page-btn <%= (i == currentPage  ? "active" : "") %>"><%= i %></a>
            <%
                }
                if (currentPage  < totalPages) {
            %>
            <a href="board-list.jsp?page=<%= (currentPage  + 1) %>&keyword=<%= keyword %>" class="page-btn">다음</a>
            <%
                    }
                }
            %>
        </div>
    </div>
</div>
