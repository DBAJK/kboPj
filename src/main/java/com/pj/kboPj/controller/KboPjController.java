package com.pj.kboPj.controller;

import com.pj.kboPj.service.KboPjService;
import com.pj.kboPj.vo.KboPjVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Controller
public class KboPjController {
    @Autowired(required = false)
    KboPjService kboPjService;

    @GetMapping("/")
    public String index(@RequestParam(value = "formType", required = false) String formType, Model model) {
        if (formType == null) {
            formType = "mainForm"; // 기본값
        }
        model.addAttribute("formType", formType);
        return "indexForm"; // => indexForm.jsp 출력
    }
    // 별도 URL을 통한 접근도 허용하려면 redirect 사용 가능
    @GetMapping("/loginForm")
    public String loginRedirect() {
        return "redirect:/?formType=login";
    }

    @GetMapping("/joinForm")
    public String joinRedirect() {
        return "redirect:/?formType=join";
    }
    @GetMapping("/myPage")
    public String myPageRedirect() {
        return "redirect:/?formType=myPage";
    }

    @GetMapping("/mainForm")
    public String mainFormRedirect() {
        return "redirect:/?formType=mainForm";
    }
    @GetMapping("/baseballGame")
    public String baseballGameRedirect() {
        return "redirect:/?formType=baseballGame";
    }
    @GetMapping("/scoreBoard")
    public String scoreBoardRedirect() {
        return "redirect:/?formType=scoreBoard";
    }


    @GetMapping("/fanBulletinBoard")
    public String fanBulletinBoardRedirect() {
        return "redirect:/?formType=fanBulletinBoard";
    }

    // 회원가입
    @RequestMapping("/saveJoinForm")
    @ResponseBody
    public void saveJoinForm(KboPjVO vo){
        try {
            kboPjService.saveJoinForm(vo);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    // 회원가입 아이디 체크
    @RequestMapping("/idCheck")
    @ResponseBody
    public String idCheck(@RequestParam("userId") String userId){
        int cntChk=0;
        String cnt="0";
        try {
            cntChk = kboPjService.idCheck(userId);
            if(cntChk == 1){
                cnt = "1";
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return cnt;
    }

    // 로그인 하기
    @RequestMapping(value = "/service/loginForm", produces = "text/plain; charset=UTF-8")
    @ResponseBody
    public String loginCheck(HttpServletRequest request, KboPjVO vo) {
        String userName = "";
        vo.setUserId(request.getParameter("userId"));
        vo.setUserPwd(request.getParameter("userPwd"));
        KboPjVO userChk = kboPjService.userChk(vo);

        if(userChk != null){
            HttpSession session = request.getSession();
            userName = userChk.getUserName();
            session.setAttribute("userId", vo.getUserId());
            session.setAttribute("userName", userName);
            session.setAttribute("userSeq", userChk.getUserSeq());
            session.setAttribute("userPoint", userChk.getUserPoint());
            session.setAttribute("userTeamLogo", userChk.getTeamLogo());
            session.setAttribute("userTeamName", userChk.getTeamName());
            session.setAttribute("userTeamId", userChk.getTeamId());
            return userName; // 로그인 성공
        }
        return "";
    }


    //로그아웃
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false); // 존재하는 세션만 가져옴
        if (session != null) {
            session.invalidate(); // 세션 무효화
        }
        return "redirect:/mainForm"; // 로그아웃 후 메인으로 이동
    }

    // 내 정보 조회
    @GetMapping("/myPageInfo")
    @ResponseBody
    public Map<String, Object> myPageInfo(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Map<String, Object> map = new HashMap<>();
        if (session != null && session.getAttribute("userId") != null){
            String userId = (String) session.getAttribute("userId");
            KboPjVO user = kboPjService.findUserById(userId);  // DAO 통해 정보 조회
            map.put("status", "success");
            map.put("userId", user.getUserId());
            map.put("userName", user.getUserName());
            map.put("phone", user.getUserPhoneNumber());
            map.put("point", user.getUserPoint());
            map.put("birthday", user.getUserBirty());
            map.put("email", user.getEmail());
            map.put("myTeam", user.getTeamName());
            map.put("myTeamLogo", user.getTeamLogo());
        } else {
            map.put("status", "fail");
            map.put("message", "로그인 정보가 없습니다.");
        }
        return map;
    }

    // 정보 수정
    @RequestMapping("/updateUsersInfo")
    @ResponseBody
    public void updateUsersInfo(HttpServletRequest request, KboPjVO vo){
        HttpSession session = request.getSession();
        try {
            vo.setUserId(request.getParameter("userId"));
            vo.setUserPwd(request.getParameter("userPwd"));
            vo.setUserName(request.getParameter("userName"));
            kboPjService.updateUser(vo);
            session.setAttribute("userName", request.getParameter("userName"));
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
    // 포인트 업데이트
    @PostMapping("/service/updatePoint")
    @ResponseBody
    public String updatePoint(HttpSession session, KboPjVO vo, @RequestParam("point") int point) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            return "fail";
        }
        vo.setUserId(userId);
        vo.setUserPoint(point);

        int result = kboPjService.pointUpdate(vo); // 이 메서드는 userId 기준으로 포인트 누적시키는 로직

        if (result > 0) {
            session.setAttribute("userPoint", point);
            return "success";
        } else {
            return "fail";
        }
    }

    @GetMapping("/service/fanBulletinBoard")
    public String getFanBoardListData(HttpSession session, KboPjVO vo, Model model,
                                      @RequestParam(required = false) String keyword) {
        int teamId = (int) session.getAttribute("userTeamId");
        KboPjVO param = new KboPjVO();
        param.setTeamId(teamId);
        param.setKeyword(keyword);

        List<KboPjVO> boardList = kboPjService.getBoardList(param);
        int totalCount = kboPjService.getBoardCount(param);

        model.addAttribute("boardList", boardList);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("keyword", keyword);

        return "fanBulletinBoard";
    }

    @PostMapping("/service/insertBoard")
    @ResponseBody
    public String insertFanBoard(HttpSession session, KboPjVO vo) {
        try {
            int teamId = (int) session.getAttribute("userTeamId");
            int userSeq = (int) session.getAttribute("userSeq");

            vo.setTeamId(teamId);
            vo.setUserSeq(userSeq);

            kboPjService.insertFanBoard(vo);
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }

    @PostMapping("/service/updateBoard")
    @ResponseBody
    public String updateFanBoard(HttpSession session, KboPjVO vo) {
        try {
            int teamId = (int) session.getAttribute("userTeamId");
            int userSeq = (int) session.getAttribute("userSeq");
            vo.setTeamId(teamId);
            vo.setUserSeq(userSeq);

            kboPjService.updateFanBoard(vo);
            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }

    @RequestMapping(value = "/service/deleteBoard", method = RequestMethod.POST)
    @ResponseBody
    public void delFanBoard(HttpSession session, KboPjVO vo, Model model,
                              @RequestParam("boardId") int boardId) {
        int teamId = (int) session.getAttribute("userTeamId");
        int userSeq = (int) session.getAttribute("userSeq");
        vo.setBoardId(boardId);
        vo.setTeamId(teamId);
        vo.setUserSeq(userSeq);

        kboPjService.delFanBoard(vo);
    }


    @GetMapping("/service/scoreBoard")
    public String getScoreBoard(HttpSession session, @RequestParam(required = false) String date, KboPjVO vo, Model model) {
        Integer userSeq = (Integer) session.getAttribute("userSeq");
        if (userSeq != null) {
            vo.setUserSeq(userSeq); // 세션 값이 있을 때만 설정
        } else {
            vo.setUserSeq(0);
        }

        vo.setGameDate(date);
        List<KboPjVO> games = kboPjService.getGamesByDate(vo);
        model.addAttribute("games", games);
        model.addAttribute("date", date);
        model.addAttribute("formType", "scoreBoard");
        return "scoreBoard";
    }

    @GetMapping("/service/playerStats")
    public String getPlayerStats(@RequestParam(required = false) String recordType, Model model) {
        List<KboPjVO> playerList = kboPjService.selectPlayerStats(recordType);
        model.addAttribute("playerList", playerList);
        model.addAttribute("recordType", recordType);
        model.addAttribute("formType", "mainForm");
        return "mainForm";
    }

    @RequestMapping("/service/updatePrediction")
    @ResponseBody
    public void predictionMatchInsert(HttpSession session,
                                      KboPjVO vo,
                                      @RequestParam("game_id") int gameId,
                                      @RequestParam("teamID") int teamId) {
        try {
            Integer userTeamId = (Integer) session.getAttribute("userTeamId");
            Integer userSeq = (Integer) session.getAttribute("userSeq");
            vo.setUserSeq(userSeq);
            vo.setTeamId(userTeamId);
            vo.setGame_id(gameId);
            vo.setTeamId(teamId);

            kboPjService.predictionMatchInsert(vo);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

//            ticketService.pointUpdate(vo);
}