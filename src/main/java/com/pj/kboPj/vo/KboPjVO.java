package com.pj.kboPj.vo;

import lombok.*;

@NoArgsConstructor @AllArgsConstructor
@Builder(toBuilder = true)
@Getter
@Setter
@ToString
public class KboPjVO {
    // 사용자 DB
    private String userSeq;
    private String userId;
    private String userPwd;
    private String email;
    private String userName;
    private String userBirty;
    private String userPhoneNumber;
    private int userPoint;
    private String createAt;
    private String mdfDt;

    // 팀 DB
    private String teamId;
    private String teamName;
    private String teamLogo;
    private String teamValue;

    private int playerId;
    private String recordType;
    private String name;
    private String position;
    private Integer gameCount;

    // Hitter
    private Integer hitterRank;
    private Double hraRt;
    private Double paCn;
    private Double abCn;
    private Double runCn;
    private Double hitCn;
    private Double hrCn;
    private Double rbiCn;

    // Pitcher
    private Integer pitcherRank;
    private Double eraRt;
    private String inn2Cn;
    private Double wCn;
    private Double lCn;
    private Double kkCn;

    // Defense
    private Integer defenseRank;
    private String posSc;
    private String defenInn2Cn;
    private Double errCn;
    private Double fpctRt;

    // Runner
    private Integer runnerRank;
    private Double sbaCn;
    private Double sbCn;
    private Double csCn;
    private Double sbRt;

    private String team;

    // fanBulletinBoard
    private int boardId;
    private String boardTitle;
    private String boardContent;
    private int view_cnt;
    private String reg_dt;

    private String offset;
    private String pageSize;

    private String keyword;
    private int page;
}
