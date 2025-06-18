package com.pj.kboPj.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pj.kboPj.dao.KboPjDAO;
import com.pj.kboPj.vo.KboPjVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class KboPjService {
    private final ObjectMapper objectMapper = new ObjectMapper(); // ObjectMapper 인스턴스 생성

    @Autowired(required = false)
    private KboPjDAO kboPjDAO;


    public void saveJoinForm(KboPjVO vo) throws Exception{
        kboPjDAO.saveJoinForm(vo);
    }

    public int idCheck(String userId) throws Exception{
        return kboPjDAO.idCheck(userId);
    }

    public KboPjVO userChk(KboPjVO vo){
        return kboPjDAO.userChk(vo);
    }

    public KboPjVO findUserById(String userId){
        return kboPjDAO.findUserById(userId);
    }

    public void updateUser(KboPjVO vo) throws Exception{
        kboPjDAO.updateUser(vo);
    }

    public int  pointUpdate(KboPjVO vo) {
        return kboPjDAO.pointUpdate(vo);
    }

    public List<KboPjVO> selectPlayerStats(Map<String, String> params){
        return kboPjDAO.selectPlayerStats(params);
    }

    public List<KboPjVO> getBoardList(KboPjVO vo){
        return kboPjDAO.selectAllBoards(vo);
    }
    public int getBoardCount(KboPjVO vo){
        return kboPjDAO.countBoards(vo);
    }
    public List<KboPjVO> getGamesByDate(String date) {
        List<KboPjVO> games = kboPjDAO.selectGamesByDate(date);

        for (KboPjVO game : games) {
            // home_innings 파싱
            Map<String, Integer> homeInnings = parseJsonToMap(game.getHome_innings());
            game.setTeam1Scores(convertInningsToList(homeInnings));

            // away_innings 파싱
            Map<String, Integer> awayInnings = parseJsonToMap(game.getAway_innings());
            game.setTeam2Scores(convertInningsToList(awayInnings));

            Map<String, Integer> parsedTeam1Total = parseJsonToMap(game.getHome_total());
            game.setTeam1Total(convertStatMapToList(parsedTeam1Total));

            Map<String, Integer> parsedTeam2Total = parseJsonToMap(game.getAway_total());
            game.setTeam2Total(convertStatMapToList(parsedTeam2Total));

        }
        return games;
    }

    private List<Integer> convertInningsToList(Map<String, Integer> innings) {
        List<Integer> scores = new ArrayList<>();
        for (int i=1; i<=12; i++) {
            scores.add(innings.getOrDefault(String.valueOf(i), 0));
        }
        return scores;
    }
    public List<Integer> convertStatMapToList(Map<String, Integer> statMap) {
        return Arrays.asList(
            statMap.getOrDefault("R", 0),
            statMap.getOrDefault("H", 0),
            statMap.getOrDefault("E", 0),
            statMap.getOrDefault("B", 0)
        );
    }

    private Map<String, Integer> parseJsonToMap(String json) {
        if (json == null || json.isEmpty()) {
            return Collections.emptyMap();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Integer>>() {});
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            return Collections.emptyMap();
        }
    }
    public int  predictionMatchUpdate(KboPjVO vo) {
        return kboPjDAO.predictionMatchUpdate(vo);
    }

}
