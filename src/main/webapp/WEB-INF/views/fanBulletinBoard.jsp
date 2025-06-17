<%--
  Created by IntelliJ IDEA.
  User: jgkim
  Date: 2025-06-12
  Time: 오후 10:36
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: 'Malgun Gothic', sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 20px;
    }
    
    .container {
        max-width: 1200px;
        margin: 0 auto;
        background: white;
        border-radius: 15px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        overflow: hidden;
    }
    
    .header {
        background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
        color: white;
        padding: 30px;
        text-align: center;
    }
    
    .header h1 {
        font-size: 2.5em;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    
    .header p {
        font-size: 1.1em;
        opacity: 0.9;
    }
    
    .board-controls {
        padding: 20px 30px;
        border-bottom: 2px solid #f8f9fa;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #f8f9fa;
    }
    
    .search-box {
        display: flex;
        gap: 10px;
        align-items: center;
    }
    
    .search-box input {
        padding: 10px 15px;
        border: 2px solid #ddd;
        border-radius: 25px;
        font-size: 14px;
        width: 250px;
        transition: all 0.3s ease;
    }
    
    .search-box input:focus {
        outline: none;
        border-color: #3498db;
        box-shadow: 0 0 10px rgba(52, 152, 219, 0.3);
    }
    
    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: 25px;
        cursor: pointer;
        font-size: 14px;
        font-weight: bold;
        transition: all 0.3s ease;
        text-decoration: none;
        display: inline-block;
        text-align: center;
    }
    
    .btn-primary {
        background: linear-gradient(135deg, #3498db, #2980b9);
        color: white;
    }
    
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
    }
    
    .btn-success {
        background: linear-gradient(135deg, #27ae60, #229954);
        color: white;
    }
    
    .btn-success:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(39, 174, 96, 0.4);
    }
    
    .board-table {
        width: 100%;
        border-collapse: collapse;
        margin: 0;
    }
    
    .board-table th {
        background: linear-gradient(135deg, #34495e, #2c3e50);
        color: white;
        padding: 15px;
        text-align: center;
        font-weight: bold;
        font-size: 14px;
    }
    
    .board-table td {
        padding: 15px;
        border-bottom: 1px solid #eee;
        text-align: center;
    }
    
    .board-table tbody tr {
        transition: all 0.3s ease;
    }
    
    .board-table tbody tr:hover {
        background: linear-gradient(135deg, #f8f9fa, #e9ecef);
        transform: scale(1.01);
    }
    
    .board-table .title {
        text-align: left;
        max-width: 400px;
    }
    
    .board-table .title a {
        color: #2c3e50;
        text-decoration: none;
        font-weight: 500;
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        transition: color 0.3s ease;
    }
    
    .board-table .title a:hover {
        color: #3498db;
        text-decoration: underline;
    }
    
    .board-table .author {
        font-weight: 500;
        color: #7f8c8d;
    }
    
    .board-table .date {
        color: #95a5a6;
        font-size: 13px;
    }
    
    .board-table .views {
        color: #e74c3c;
        font-weight: bold;
    }
    
    .pagination {
        padding: 30px;
        text-align: center;
        background: #f8f9fa;
    }
    
    .pagination a {
        display: inline-block;
        padding: 8px 12px;
        margin: 0 5px;
        color: #3498db;
        text-decoration: none;
        border: 2px solid #3498db;
        border-radius: 5px;
        transition: all 0.3s ease;
    }
    
    .pagination a:hover, .pagination a.current {
        background: #3498db;
        color: white;
        transform: translateY(-2px);
    }
    
    .no-data {
        text-align: center;
        padding: 50px;
        color: #7f8c8d;
        font-size: 18px;
    }
    
    .stats {
        background: #ecf0f1;
        padding: 15px 30px;
        display: flex;
        justify-content: space-between;
        font-size: 14px;
        color: #7f8c8d;
    }
</style>
<div class="container">
    <div class="header">
        <h1>⚽ 팬 게시판</h1>
        <p>우리 구단을 사랑하는 팬들만의 특별한 공간</p>
    </div>
    
    <div class="stats">
        <span>총 게시글: <strong>${totalCount}</strong>개</span>
        <span>오늘 작성: <strong>${todayCount}</strong>개</span>
    </div>
    
    <div class="board-controls">
        <div class="search-box">
            <form method="get" action="board-list.jsp" style="display: flex; gap: 10px;">
                <input type="text" name="keyword" placeholder="제목 또는 작성자 검색..." 
                       value="${param.keyword}">
                <button type="submit" class="btn btn-primary">검색</button>
            </form>
        </div>
        <a href="board-dtl.jsp?mode=write" class="btn btn-success">✏️ 새 글 작성</a>
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
        <tbody>
            <!-- 공지사항 (고정) -->
            <c:forEach var="notice" items="${noticeList}">
                <tr style="background: #fff3cd;">
                    <td><span style="color: #e74c3c; font-weight: bold;">공지</span></td>
                    <td class="title">
                        <a href="board-dtl.jsp?id=${notice.id}&mode=view">
                            📢 ${notice.title}
                        </a>
                    </td>
                    <td class="author">${notice.author}</td>
                    <td class="date">
                        <fmt:formatDate value="${notice.regDate}" pattern="MM-dd"/>
                    </td>
                    <td class="views">${notice.viewCount}</td>
                </tr>
            </c:forEach>
            
            <!-- 일반 게시글 -->
            <c:choose>
                <c:when test="${empty boardList}">
                    <tr>
                        <td colspan="5" class="no-data">
                            📝 아직 작성된 게시글이 없습니다.<br>
                            첫 번째 글을 작성해보세요!
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="board" items="${boardList}" varStatus="status">
                        <tr>
                            <td>${totalCount - (currentPage-1)*pageSize - status.index}</td>
                            <td class="title">
                                <a href="board-dtl.jsp?id=${board.id}&mode=view">
                                    ${board.title}
                                    <c:if test="${board.commentCount > 0}">
                                        <span style="color: #e74c3c; font-size: 12px;">[${board.commentCount}]</span>
                                    </c:if>
                                    <c:if test="${board.isNew}">
                                        <span style="color: #27ae60; font-size: 11px;">NEW</span>
                                    </c:if>
                                </a>
                            </td>
                            <td class="author">${board.author}</td>
                            <td class="date">
                                <fmt:formatDate value="${board.regDate}" 
                                    pattern="${board.isToday ? 'HH:mm' : 'MM-dd'}"/>
                            </td>
                            <td class="views">${board.viewCount}</td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
    
    <!-- 페이징 -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="?page=1&keyword=${param.keyword}">《</a>
                <a href="?page=${currentPage-1}&keyword=${param.keyword}">‹</a>
            </c:if>
            
            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                <a href="?page=${i}&keyword=${param.keyword}" 
                   class="${i == currentPage ? 'current' : ''}">${i}</a>
            </c:forEach>
            
            <c:if test="${currentPage < totalPages}">
                <a href="?page=${currentPage+1}&keyword=${param.keyword}">›</a>
                <a href="?page=${totalPages}&keyword=${param.keyword}">》</a>
            </c:if>
        </div>
    </c:if>
</div>

<script>
    // 페이지 로드 시 애니메이션
    document.addEventListener('DOMContentLoaded', function() {
        const rows = document.querySelectorAll('.board-table tbody tr');
        rows.forEach((row, index) => {
            row.style.opacity = '0';
            row.style.transform = 'translateY(20px)';
            setTimeout(() => {
                row.style.transition = 'all 0.5s ease';
                row.style.opacity = '1';
                row.style.transform = 'translateY(0)';
            }, index * 100);
        });
    });
    
    // 검색 기능 개선
    document.querySelector('input[name="keyword"]').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            this.closest('form').submit();
        }
    });
</script>
