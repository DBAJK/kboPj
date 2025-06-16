package com.pj.kboPj.service;

import com.pj.kboPj.dao.KboPjDAO;
import com.pj.kboPj.vo.KboPjVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class KboPjService {

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

}
