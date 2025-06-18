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

    List<KboPjVO> selectPlayerStats(Map<String, String> params);

    List<KboPjVO> selectAllBoards(KboPjVO vo);
    int countBoards(KboPjVO vo);
    List<KboPjVO> selectGamesByDate(String date);

    int predictionMatchUpdate(KboPjVO vo);

}
