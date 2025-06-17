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
<link href="/resources/css/boardStyle.css" rel="stylesheet" type="text/css">
<script src="https://code.jquery.com/jquery-3.4.1.js"></script>
<div class="body-head-container">
<div class="body-container">
    <div class="board-header">
        <h1 class="h1-header"><span><img id="userTeamLogo" style="width:100px; height:100px;"/></span>팬 게시판</h1>
        <p>우리 구단을 사랑하는 팬들만의 특별한 공간</p>
    </div>

    <div class="stats">
        <span>총 게시글: <strong>${totalCount}</strong>개</span>
    </div>

    <div class="board-controls">
        <div class="search-box">
            <form method="get" action="board-list.jsp" style="display: flex; gap: 10px;">
                <input type="text" name="keyword" placeholder="제목 또는 작성자 검색..."
                       value="${param.keyword}">
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
        <tbody id="boardListContainer"></tbody>
    </table>

    <div id="paginationContainer" class="pagination-container"></div>
</div>
</div>

<script>
    let allItems = [];
    let currentPage = 1;
    const itemsPerPage = 10;
    let totalCount = 0;

    function fetchBoardList(page, keyword) {
        $.ajax({
            url: '/service/fanBoardListData',
            method: 'GET',
            data: { page: page, keyword: keyword },
            success: function (res) {
                const boardList = res.boardList;
                totalCount = res.totalCount; // 전역 변수 갱신
                currentPage = res.currentPage;

                const $container = $('#boardListContainer');
                $container.empty();
                // team 로고 넣기
                const userTeamLogo = '<c:out value="${sessionScope.userTeamLogo}" default="" />';
                $("#userTeamLogo").attr("src", userTeamLogo || "");

                if (!boardList || boardList.length === 0) {
                    $container.append(`
                        <tr>
                            <td colspan="5" class="no-data">
                                아직 작성된 게시글이 없습니다.<br>
                                첫 번째 글을 작성해보세요!
                            </td>
                        </tr>
                    `);
                    $('#paginationContainer').empty();
                    return;
                }

                boardList.forEach((board, index) => {
                    const formattedDate = board.reg_dt?.length >= 16
                        ? board.reg_dt.substring(11, 16)
                        : board.reg_dt.substring(5, 10);

                    const boardNo = totalCount - ((currentPage - 1) * itemsPerPage + index);

                    $container.append(`
                        <tr>
                            <td>${'${boardNo}'}</td>
                            <td class="title">
                                <a href="fanBulletinBoardDtl?id=${'${board.boardId}'}&mode=view">
                                    ${'${board.boardTitle}'}
                                </a>
                            </td>
                            <td class="author">${'${board.userName}'}</td>
                            <td class="date">${'${formattedDate}'}</td>
                            <td class="views">${'${board.view_cnt}'}</td>
                        </tr>
                    `);
                });
                renderPagination();
            },
            error: function () {
                alert('게시글 로딩 중 오류가 발생했습니다.');
            }
        });
    }

    function renderPagination() {
        const totalPages = Math.ceil(allItems.length / itemsPerPage);
        const pagination = document.getElementById('paginationContainer');
        pagination.innerHTML = '';

        if (totalPages <= 1) return;

        // 이전 버튼
        const prevBtn = document.createElement('button');
        prevBtn.textContent = '이전';
        prevBtn.disabled = currentPage === 1;
        prevBtn.onclick = () => {
            if (currentPage > 1) {
                currentPage--;
                renderCurrentPage();
                renderPagination();
            }
        };
        pagination.appendChild(prevBtn);

        // 페이지 번호 버튼
        const maxVisiblePages = 5;
        let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
        let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
        if (endPage - startPage < maxVisiblePages - 1) {
            startPage = Math.max(1, endPage - maxVisiblePages + 1);
        }

        if (startPage > 1) {
            const firstBtn = document.createElement('button');
            firstBtn.textContent = '1';
            firstBtn.onclick = () => goToPage(1);
            pagination.appendChild(firstBtn);
            if (startPage > 2) {
                const ellipsis = document.createElement('span');
                ellipsis.textContent = '...';
                pagination.appendChild(ellipsis);
            }
        }

        for (let i = startPage; i <= endPage; i++) {
            const pageBtn = document.createElement('button');
            pageBtn.textContent = i;
            if (i === currentPage) pageBtn.classList.add('active');
            pageBtn.onclick = () => goToPage(i);
            pagination.appendChild(pageBtn);
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) {
                const ellipsis = document.createElement('span');
                ellipsis.textContent = '...';
                pagination.appendChild(ellipsis);
            }
            const lastBtn = document.createElement('button');
            lastBtn.textContent = totalPages;
            lastBtn.onclick = () => goToPage(totalPages);
            pagination.appendChild(lastBtn);
        }

        // 다음 버튼
        const nextBtn = document.createElement('button');
        nextBtn.textContent = '다음';
        nextBtn.disabled = currentPage === totalPages;
        nextBtn.onclick = () => {
            if (currentPage < totalPages) {
                currentPage++;
                renderCurrentPage();
                renderPagination();
            }
        };
        pagination.appendChild(nextBtn);

        // 페이지 정보
        const pageInfo = document.createElement('div');
        pageInfo.textContent = `${currentPage} / ${totalPages} 페이지 (총 ${allItems.length}개)`;
        pagination.appendChild(pageInfo);
    }

    // 현재 페이지 데이터 렌더링
    function renderCurrentPage() {
        const tbody = document.getElementById('tableBody');
        tbody.innerHTML = '';

        if (allItems.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4">데이터가 없습니다.</td></tr>';
            return;
        }
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        const currentItems = allItems.slice(startIndex, endIndex);

        currentItems.forEach(item => {
            const row = document.createElement('tr');
            // item의 속성에 맞게 셀을 채워주세요
            row.innerHTML = `<td>${item.id}</td><td>${item.title}</td>`;
            tbody.appendChild(row);
        });
    }

    function goToPage(page) {
        currentPage = page;
        renderCurrentPage();
        renderPagination();
    }

    // 데이터가 준비되면 호출
    function initPagination(data) {
        allItems = data;
        currentPage = 1;
        renderCurrentPage();
        renderPagination();
    }

    $(document).ready(function () {
        const urlParams = new URLSearchParams(window.location.search);
        currentPage = parseInt(urlParams.get('page')) || 1;
        const keyword = urlParams.get('keyword') || '';
        fetchBoardList(currentPage, keyword);

        $('form').on('submit', function (e) {
            e.preventDefault();
            const keyword = $('input[name="keyword"]').val();
            fetchBoardList(1, keyword);
        });
        $('input[name="keyword"]').on('keypress', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                $('form').submit();
            }
        });
    });

</script>
