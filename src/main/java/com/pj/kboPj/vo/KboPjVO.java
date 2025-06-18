package com.pj.kboPj.vo;

import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    private int game_id;
    private String gameDate;
    private String game_date;
    private int home_team_id;
    private int away_team_id;
    private String venue;
    private int home_score;
    private int away_score;
    private String home_innings; // DB에서 읽은 JSON 문자열
    private String away_innings;
    private String home_total;
    private String away_total;
    private String team1Name;
    private String team2Name;
    private String team1Class;
    private String team2Class;

    private List<Integer> team1Scores;
    private List<Integer> team2Scores;
    private List<Integer> team1Total;
    private List<Integer> team2Total;

}
