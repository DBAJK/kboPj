package com.pj.kboPj.dao;

import com.pj.kboPj.vo.KboPjVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Mapper
public interface KboPjDAO {
    int idCheck(String userId) throws Exception;

    void saveJoinForm(KboPjVO vo) throws Exception;

    KboPjVO userChk(KboPjVO vo);

    KboPjVO findUserById(String userId);

    void updateUser(KboPjVO vo) throws Exception;

    int pointUpdate(KboPjVO vo);

    List<KboPjVO> selectPlayerStats(String recordType);

    List<KboPjVO> selectAllBoards(KboPjVO vo);
    int countBoards(KboPjVO vo);

    void delFanBoard(KboPjVO vo);

    void insertFanBoard(KboPjVO vo);
    void updateFanBoard(KboPjVO vo);

    List<KboPjVO> selectGamesByDate(KboPjVO vo);

    int insertPredictionMatch(KboPjVO vo);
    List<KboPjVO> getUnjudgedPredictions(int userSeq);
    Integer findWinnerTeamIdByGameId(int gameId);
    void updatePredictionResult(KboPjVO prediction);

}
