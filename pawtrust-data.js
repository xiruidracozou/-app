/**
 * 爪印识途 PawTrust V2 — 核心城市合规库、空间多边形边界 (Polygon Zones) 与 AI 安全智算数据层
 * ⚠️ 声明：本文件内所有城市规则与地点均为【演示数据、未核实、不能当法律依据】。正式产品需以各城市官方条例为准。
 */

window.PAWTRUST_DATA = {
  disclaimer: "演示数据、未核实、不能当法律依据 · 高温提示不可替代兽医建议",

  cities: {
    shenzhen: {
      id: "shenzhen",
      name: "深圳",
      stage: "首发六城",
      center: [22.5465, 114.0250],
      zoom: 13,
      defaultTemp: 26,
      defaultHumidity: 74,
      leashShort: "限绳 1.5m",
      mapCoordStandard: "GCJ-02 审图号合规坐标系",
      openDataNote: "官方宠物公园约 11-12 个，非公园绿地与商家靠持证养犬人 UGC 互核积累",
      compliance: {
        authority: "《深圳市养犬管理条例》及 2024.7 禁养名录（演示数据未核实）",
        leashRule: "户外全程牵绳（≤1.5 米）；仅官方指定宠物公园「双重门围栏放绳区」内可解绳。",
        parkBanRule: "普通市政公园普遍禁狗（地图以红色禁区展示，严禁标为可遛）；仅官方宠物公园及公园红线外市政绿地可进入。",
        bannedBreedsCount: 38,
        bannedBreedsSample: ["比特斗牛梗", "藏獒", "阿根廷杜高犬", "巴西非勒犬", "日本土佐犬", "卡斯罗犬", "罗威纳犬", "德国牧羊犬", "秋田犬", "牛头梗"],
        penalties: [
          "饲养 38 种禁养烈性犬：2024 年 7 月 5 日起，罚款 5,000 元并没收犬只",
          "2026 年 1 月 1 日全国新规生效：公共场所不牵绳最高罚款 200 元，情节严重可处行政拘留",
          "未清理犬只粪便：罚款 500 元；无证养犬逾期不改罚款 2,000 元"
        ],
        licenseRequirement: "深圳全面实行电子犬证 + 芯片登记，年审免费。"
      }
    },
    beijing: {
      id: "beijing",
      name: "北京",
      stage: "首发六城",
      center: [39.9455, 116.4720],
      zoom: 14,
      defaultTemp: 24,
      defaultHumidity: 45,
      leashShort: "限绳 1.5m · 限高35cm",
      mapCoordStandard: "GCJ-02 审图号合规坐标系",
      openDataNote: "重点管理区五环内限高 35cm，亮马河沿岸开放水岸与朝阳公园封闭红线相邻",
      compliance: {
        authority: "《北京市养犬管理规定》（演示数据未核实）",
        leashRule: "出户必须束犬链（≤1.5 米），由成年人牵领；携犬乘电梯须戴嘴套或入犬袋。",
        parkBanRule: "市属及区属普通公园全面禁入；仅部分河道敞开式滨水步道（非公园围栏管理段）可通行。",
        bannedBreedsCount: 34,
        bannedBreedsSample: ["藏獒", "比特犬", "德国牧羊犬", "罗威纳犬", "大丹犬", "圣伯纳犬", "高加索犬", "重点管理区体高超 35cm 大型犬"],
        penalties: [
          "重点管理区饲养烈性犬或超 35cm 大型犬：没收犬只并处 5,000 元罚款",
          "2026 年 1 月 1 日全国新规：不牵绳最高罚 200 元，严重者行政拘留"
        ],
        licenseRequirement: "重点管理区每户限养一犬，须年度年检与狂犬免疫登记。"
      }
    },
    shanghai: {
      id: "shanghai",
      name: "上海",
      stage: "首发六城",
      center: [31.1960, 121.4950],
      zoom: 13,
      defaultTemp: 23,
      defaultHumidity: 68,
      leashShort: "限绳 2.0m · 大犬嘴套",
      mapCoordStandard: "GCJ-02 审图号合规坐标系",
      openDataNote: "徐汇滨江指定萌宠园与世纪公园外围市政步道形成鲜明分区对照",
      compliance: {
        authority: "《上海市养犬管理条例》（演示数据未核实）",
        leashRule: "牵绳不得超过 2 米；身高 35cm 以上大型犬出户必须佩戴嘴套。",
        parkBanRule: "城市公园普遍禁入；徐汇滨江等仅限「萌宠园围栏专区」凭电子犬证预约进入。",
        bannedBreedsCount: 21,
        bannedBreedsSample: ["藏獒", "罗威纳犬", "意大利扭玻利顿", "波尔多獒犬", "牛头梗", "斯塔福梗", "比特犬", "阿富汗猎犬", "高加索牧羊犬"],
        penalties: [
          "未牵绳或大型犬未戴嘴套：处 50–200 元罚款；2026 全国新规严重可拘留",
          "个人饲养烈性犬：收容犬只并吊销《养犬登记证》"
        ],
        licenseRequirement: "一户一犬制，需持有上海市公安局签发的电子《养犬登记证》。"
      }
    },
    guangzhou: {
      id: "guangzhou",
      name: "广州",
      stage: "首发六城",
      center: [23.1128, 113.3685],
      zoom: 14,
      defaultTemp: 29,
      defaultHumidity: 78,
      leashShort: "限绳 1.5m",
      mapCoordStandard: "GCJ-02 审图号合规坐标系",
      openDataNote: "珠江沿岸非公园市政绿带与传统禁犬公园边界需靠实拍核实",
      compliance: {
        authority: "《广州市养犬管理条例》（演示数据未核实）",
        leashRule: "严格管理区内犬绳不超过 1.5 米；体高满 71cm 犬只须戴犬口罩。",
        parkBanRule: "市政公园全天禁狗；沿江开放式市政道路绿带需确认现场无禁牌。",
        bannedBreedsCount: 36,
        bannedBreedsSample: ["比特斗牛梗", "斯塔福梗", "阿根廷杜高犬", "巴西非勒犬", "日本土佐犬", "藏獒", "德国牧羊犬", "罗威纳犬", "牛头梗"],
        penalties: [
          "饲养 36 种危险犬：每只罚款 5,000 元并没收犬只",
          "未牵犬绳：处 50–200 元罚款（配合 2026 全国新规执行）"
        ],
        licenseRequirement: "通过「广州养犬服务通」办理电子犬证，严格管理区一户一犬。"
      }
    },
    hangzhou: {
      id: "hangzhou",
      name: "杭州",
      stage: "首发六城",
      center: [30.2215, 120.2148],
      zoom: 14,
      defaultTemp: 22,
      defaultHumidity: 62,
      leashShort: "限绳 1.5m · 限溜时段",
      mapCoordStandard: "GCJ-02 审图号合规坐标系",
      openDataNote: "钱塘江滨江绿道与社区开放草坪为主要合规空间",
      compliance: {
        authority: "《杭州市限制养犬规定》（演示数据未核实）",
        leashRule: "出户必须系犬链（≤1.5 米）并由成年人牵领；重点限养区限高 45cm、限长 60cm。",
        parkBanRule: "西湖景区主公园及市政公园禁止携犬进入；开放式河岸市政步道按规定时段通行。",
        bannedBreedsCount: 34,
        bannedBreedsSample: ["藏獒", "比特斗牛梗", "牛头梗", "杜宾犬", "罗威纳犬", "德国牧羊犬", "秋田犬", "大丹犬"],
        penalties: [
          "未束犬链或违反规定：处 200–1,000 元罚款；情节严重没收犬只并吊销许可证",
          "擅自养犬：没收犬只，处 3,000–5,000 元罚款"
        ],
        licenseRequirement: "通过「浙里办 / 贴心城管」申领电子犬证。"
      }
    },
    chengdu: {
      id: "chengdu",
      name: "成都",
      stage: "首发六城",
      center: [30.4682, 104.0695],
      zoom: 14,
      defaultTemp: 21,
      defaultHumidity: 66,
      leashShort: "限绳 1.5m",
      mapCoordStandard: "GCJ-02 审图号合规坐标系",
      openDataNote: "麓湖宠物友好岛等示范社区具备清晰的围栏放绳与街区牵绳分区",
      compliance: {
        authority: "《成都市养犬管理条例》（演示数据未核实）",
        leashRule: "携犬出户须系犬绳（≤1.5 米），由完全民事行为能力人牵领。",
        parkBanRule: "传统市政公园禁止犬只入内；天府绿道及开放社区草坪依现场标识通行。",
        bannedBreedsCount: 22,
        bannedBreedsSample: ["比特斗牛梗犬", "斯塔福梗犬", "阿根廷杜高犬", "巴西非勒犬", "日本土佐犬", "卡斯罗犬", "中亚牧羊犬", "藏獒", "德国牧羊犬"],
        penalties: [
          "饲养禁养犬种：强制收容犬只，个人处 500–2,000 元罚款",
          "不牵犬绳出户：拒不改正处 50–200 元罚款（叠加 2026 全国新规）"
        ],
        licenseRequirement: "通过「蓉城犬管」办理电子犬证。"
      }
    },
    hongkong: {
      id: "hongkong",
      name: "香港",
      stage: "Phase 2 候选 · 开放数据示范",
      center: [22.3120, 114.1750],
      zoom: 13,
      defaultTemp: 27,
      defaultHumidity: 80,
      leashShort: "≥20kg 限绳2m",
      mapCoordStandard: "WGS-84 (data.gov.hk 康文署/食环署/天文台开放数据)",
      openDataNote: "康文署 55 个宠物公园 + 180 个共享宠物公园 JSON、食环署约 1,000 间持牌餐厅",
      compliance: {
        authority: "香港《狂犬病条例》(Cap. 167D)（演示数据未核实）",
        leashRule: "20kg 或以上大型犬于公众地方须用 ≤2 米狗带牵引；4 类格斗犬须戴口罩且狗带 ≤1.5 米。",
        parkBanRule: "严密区分康文署「宠物公园 (围栏内可放绳)」与「宠物共享公园 (全程必牵绳，严禁放绳)」！",
        bannedBreedsCount: 4,
        bannedBreedsSample: ["比特斗牛梗 (Pit Bull Terrier)", "日本土佐犬 (Japanese Tosa)", "阿根廷杜高犬 (Dogo Argentino)", "巴西非勒犬 (Fila Braziliero)"],
        penalties: [
          "违反 Cap. 167D 格斗犬或大型犬牵引规定：最高罚款 HK$50,000 及监禁 6 个月",
          "不清狗粪：定额罚款 HK$3,000；无牌照或未续期疫苗最高罚 HK$10,000"
        ],
        licenseRequirement: "满 5 个月狗只须植入微型芯片并向渔护署申领牌照。"
      }
    }
  },

  // 演示地点（含精确空间区域多边形 zones，用于在地图上直接画出「围栏放绳区」「共享牵绳区」「普通公园禁狗红线区」）
  spots: [
    // ================= 深圳 =================
    {
      id: "sz-1",
      city: "shenzhen",
      name: "景田北六街社区宠物公园",
      shortName: "景田宠物公园",
      category: "pet_park",
      subType: "官方指定宠物公园 · 含围栏放绳区 + 外围牵绳区",
      parkZoneMode: "dual_zone",
      oneLineRule: "双门围栏内可放绳 · 外围步道必牵绳 (≤1.5m)",
      parkZoneDetail: "围栏放绳区（绿色实线框）设双重弹簧门，分大中小型犬区可解绳；跨出围栏进入外围共享区（琥珀色虚线框）必须立即系绳。",
      lat: 22.5568,
      lng: 114.0412,
      address: "福田区景田北六街与景田北路交汇处",
      leashStatus: "fenced_offleash",
      leashLabel: "围栏可放绳",
      zones: [
        {
          type: "offleash", // 绿色实线多边形
          label: "围栏放绳区 (Off-Leash)",
          coords: [[22.5576, 114.0402], [22.5576, 114.0422], [22.5561, 114.0422], [22.5561, 114.0402]]
        },
        {
          type: "onleash", // 琥珀色虚线外围共享区
          label: "外围共享牵绳区 (On-Leash ≤1.5m)",
          coords: [[22.5586, 114.0390], [22.5586, 114.0434], [22.5552, 114.0434], [22.5552, 114.0390]]
        }
      ],
      facilities: {
        water: true,
        waterNote: "直饮水桩稳定可用（附不锈钢狗碗）",
        shade: true,
        shadeRate: 65,
        fence: true,
        fenceNote: "1.8米高双重防逃逸弹簧门",
        sizeZone: true,
        sizeZoneNote: "独立小型犬区(<10kg)与中大型犬区"
      },
      fee: "免费",
      openHours: "07:00 - 22:00（周一上午消杀）",
      lastVerifiedDate: "2026-11-05",
      daysSinceVerified: 3,
      verifyCount: 42,
      disputeCount: 1,
      closedVotes: 0,
      trustScore: 96,
      status: "verified",
      legalBasisType: "区城管局官方挂牌宠物主题公园",
      legalBasisWhy: "福田区官方建设宠物公园，围栏内具备明确解绳豁免，外围人行道按市政条例牵绳。",
      fieldSignal: "信号满格，夜间有照明，草坪排水快。",
      verifiedPhotos: [
        { user: "阿柴麻麻 (深A·10294)", time: "3天前", tag: "双重门锁完好·水源正常" },
        { user: "边牧闪电爸 (深A·88492)", time: "6天前", tag: "早间消杀已完成" }
      ]
    },
    {
      id: "sz-5",
      city: "shenzhen",
      name: "莲花山公园（市政公园禁狗对照区）",
      shortName: "莲花山 · 禁犬对照",
      category: "banned_park",
      subType: "普通市政公园 · 全园禁狗红线对照区",
      parkZoneMode: "banned",
      oneLineRule: "普通市政公园红线内严禁携犬入内（含宠物推车）",
      parkZoneDetail: "地图红色区域为莲花山公园管理红线，各出入口均有安保与禁犬立牌。仅作为对照点帮狗主避坑，请改去西北侧 1.8km 外的景田宠物公园。",
      lat: 22.5531,
      lng: 114.0583,
      address: "福田区红荔路 6030 号",
      leashStatus: "banned",
      leashLabel: "禁狗对照点",
      zones: [
        {
          type: "banned", // 红色禁区多边形
          label: "市政公园禁犬红线区（不可遛）",
          coords: [[22.5610, 114.0500], [22.5615, 114.0665], [22.5465, 114.0675], [22.5460, 114.0510]]
        }
      ],
      facilities: {
        water: false,
        waterNote: "禁止入内",
        shade: true,
        shadeRate: 80,
        fence: false,
        fenceNote: "全园禁犬",
        sizeZone: false,
        sizeZoneNote: "全园禁犬"
      },
      fee: "禁狗对照",
      openHours: "全天禁犬",
      lastVerifiedDate: "2026-11-04",
      daysSinceVerified: 4,
      verifyCount: 64,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 99,
      status: "banned_reference",
      legalBasisType: "《深圳市公园管理条例》市政公园禁犬规定",
      legalBasisWhy: "普通公园只作为禁狗对照点展示，明确不可遛，绝不标成可遛地点。",
      fieldSignal: "南门、西门、东北门均有安保劝返。",
      verifiedPhotos: [
        { user: "福田志愿者 (深A·00921)", time: "4天前", tag: "入口立牌明确禁犬" }
      ]
    },
    {
      id: "sz-2",
      city: "shenzhen",
      name: "大沙河西岸市政退线绿化带（非公园段）",
      shortName: "大沙河退线绿带",
      category: "non_park_green",
      subType: "市政道路附属绿化带 · 非公园管理红线",
      parkZoneMode: "onleash_only",
      oneLineRule: "公园闸机外市政退线草坡 · 全程必须牵绳 (≤1.5m)",
      parkZoneDetail: "位于大沙河公园围栏闸口外侧，属沙河西路市政道路退线绿化带，不在公园禁犬红线内，持证牵绳合规通行。",
      lat: 22.5482,
      lng: 113.9564,
      address: "南山区沙河西路辅道东侧退线草坡",
      leashStatus: "onleash_required",
      leashLabel: "必须牵绳",
      zones: [
        {
          type: "onleash",
          label: "非公园市政绿化带走廊（全程牵绳）",
          coords: [[22.5540, 113.9548], [22.5540, 113.9578], [22.5425, 113.9585], [22.5425, 113.9552]]
        }
      ],
      facilities: {
        water: false,
        waterNote: "需自备饮水壶（500m外有便利店）",
        shade: true,
        shadeRate: 78,
        fence: false,
        fenceNote: "开放式草坡，紧邻辅道须握紧牵引绳",
        sizeZone: false,
        sizeZoneNote: "无分区"
      },
      fee: "免费",
      openHours: "全天开放",
      lastVerifiedDate: "2026-11-01",
      daysSinceVerified: 7,
      verifyCount: 19,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 89,
      status: "verified",
      legalBasisType: "市政道路附属绿化带（非公园管理范围）",
      legalBasisWhy: "不属于市政公园管理红线范围，现场无禁犬立牌，持证牵绳合规。",
      fieldSignal: "树冠浓密遮阴好，切勿跨入南侧大沙河公园正式闸口内。",
      verifiedPhotos: [
        { user: "金毛奥利奥 (深B·39104)", time: "7天前", tag: "现场无禁狗牌·安保不驱赶" }
      ]
    },
    {
      id: "sz-3",
      city: "shenzhen",
      name: "Bark & Brew 爪印咖啡（OCT创意园店）",
      shortName: "Bark & Brew 咖啡",
      category: "pet_merchant",
      subType: "宠物友好商家 · 室内空调+庭院全开放",
      parkZoneMode: "onleash_only",
      oneLineRule: "允许进入室内空调区 · 全体型友好 · 需牵绳",
      parkZoneDetail: "真宠物友好（非仅限小型犬）：实测 30kg+ 金毛/拉布拉多可进室内吹空调，提供免费冰水碗与拾便袋。",
      lat: 22.5392,
      lng: 113.9918,
      address: "南山区华侨城创意文化园北区 B3 栋 104",
      merchantRules: {
        allowIndoor: "允许进入室内空调区及外摆庭院",
        sizeLimit: "全体型友好（谢绝 38 种禁养烈性犬）",
        leashReq: "室内需牵绳固定于桌扣"
      },
      leashStatus: "onleash_required",
      leashLabel: "室内可进·牵绳",
      zones: [
        {
          type: "offleash",
          label: "宠物友好商业外摆及室内区",
          coords: [[22.5404, 113.9906], [22.5404, 113.9930], [22.5380, 113.9930], [22.5380, 113.9906]]
        }
      ],
      facilities: {
        water: true,
        waterNote: "店员免费提供宠物饮用水及水碗",
        shade: true,
        shadeRate: 95,
        fence: true,
        fenceNote: "外摆院子带 1.2m 木质围栏",
        sizeZone: false,
        sizeZoneNote: "大狗友好"
      },
      fee: "人均 ¥38",
      openHours: "09:30 - 20:30",
      lastVerifiedDate: "2026-11-06",
      daysSinceVerified: 2,
      verifyCount: 31,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 95,
      status: "verified",
      legalBasisType: "商业物业自主经营宠物友好店铺",
      legalBasisWhy: "创意园物业与店铺均允许持证犬只入内，高温天避暑首选。",
      fieldSignal: "室内瓷砖地面清凉，无需担心 52°C 柏油路烫爪。",
      verifiedPhotos: [
        { user: "拉布拉多花生 (深A·55201)", time: "2天前", tag: "32kg拉布拉多实测可进室内" }
      ]
    },
    {
      id: "sz-4",
      city: "shenzhen",
      name: "前海桂湾河岸北侧闲置草坪",
      shortName: "桂湾草坪 · 待复核",
      category: "non_park_green",
      subType: "河岸空地 · 超过 90 天无人复核自动降级",
      parkZoneMode: "onleash_only",
      oneLineRule: "已超 108 天无人复核 · 信任分降级至 52 · 待现场确认",
      parkZoneDetail: "系统自动触发【90天过期规则】：距上次核实已 108 天，状态置为「待复核」，需持证狗友到场拍照复核是否仍可通行。",
      lat: 22.5265,
      lng: 113.9024,
      address: "南山区前海桂湾四路北侧河岸草地",
      leashStatus: "onleash_required",
      leashLabel: "待复核 (>90天)",
      zones: [
        {
          type: "onleash",
          label: "超90天待复核区域",
          coords: [[22.5282, 113.9005], [22.5282, 113.9045], [22.5248, 113.9045], [22.5248, 113.9005]]
        }
      ],
      facilities: {
        water: false,
        waterNote: "无水源",
        shade: false,
        shadeRate: 20,
        fence: false,
        fenceNote: "无围栏",
        sizeZone: false,
        sizeZoneNote: "无分区"
      },
      fee: "免费",
      openHours: "全天",
      lastVerifiedDate: "2026-07-23",
      daysSinceVerified: 108,
      verifyCount: 8,
      disputeCount: 1,
      closedVotes: 0,
      trustScore: 52,
      status: "needs_reverify",
      legalBasisType: "河岸待开发空地（非市政公园编内）",
      legalBasisWhy: "早期属于未移交公园管养的留白绿地，因超 90 天未复核已自动降级。",
      fieldSignal: "点击下方「确认属实」可演示到场复核立即恢复信任分至 91。",
      verifiedPhotos: []
    },
    {
      id: "sz-pending-1",
      city: "shenzhen",
      name: "梅林水库下游东侧社区街头绿地",
      shortName: "梅林街角绿地 (1/2)",
      category: "non_park_green",
      subType: "新提交地点 · 待核实 (1/2 人)",
      parkZoneMode: "onleash_only",
      oneLineRule: "新发布待核实 (1/2) · 再需 1 人核实即进入公开列表",
      parkZoneDetail: "发布者已上传首张实拍，按规则不直接上公开首页；满 2 位持证用户核实通过后正式公开。",
      lat: 22.5705,
      lng: 114.0342,
      address: "福田区下梅林梅丽路东侧街角草坪",
      leashStatus: "onleash_required",
      leashLabel: "待核实 1/2",
      zones: [
        {
          type: "onleash",
          label: "待核实社区绿地 (1/2)",
          coords: [[22.5718, 114.0330], [22.5718, 114.0355], [22.5692, 114.0355], [22.5692, 114.0330]]
        }
      ],
      facilities: {
        water: false,
        waterNote: "无水源",
        shade: true,
        shadeRate: 70,
        fence: false,
        fenceNote: "三面灌木合围",
        sizeZone: false,
        sizeZoneNote: "无分区"
      },
      fee: "免费",
      openHours: "全天",
      lastVerifiedDate: "2026-11-07",
      daysSinceVerified: 1,
      verifyCount: 1,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 68,
      status: "pending_2_votes",
      legalBasisType: "街道社区管养绿地（非梅林公园红线内）",
      legalBasisWhy: "不属于梅林公园管理范围，无禁狗标识。",
      fieldSignal: "还差 1 票核实即可解锁进入公开列表。",
      verifiedPhotos: []
    },

    // ================= 北京 =================
    {
      id: "bj-1",
      city: "beijing",
      name: "亮马河国际风情水岸（北岸市政步道段）",
      shortName: "亮马河北岸绿道",
      category: "non_park_green",
      subType: "市政河岸绿道 · 非封闭公园管辖段",
      parkZoneMode: "onleash_only",
      oneLineRule: "开放式河岸景观带 · 全程牵绳 (≤1.5m) · 勿入南侧朝阳公园",
      parkZoneDetail: "亮马河北岸属水务及街道开放式河岸步道（琥珀色走廊），持证牵绳合规；南侧紧邻的朝阳公园围栏区（红色禁区）严禁入内。",
      lat: 39.9485,
      lng: 116.4682,
      address: "朝阳区亮马河北路沿河开放步道",
      leashStatus: "onleash_required",
      leashLabel: "必须牵绳 ≤1.5m",
      zones: [
        {
          type: "onleash",
          label: "亮马河开放河岸牵绳走廊",
          coords: [[39.9502, 116.4610], [39.9502, 116.4760], [39.9470, 116.4760], [39.9470, 116.4610]]
        }
      ],
      facilities: { water: true, waterNote: "沿途外摆店提供水盆", shade: true, shadeRate: 68, fence: false, fenceNote: "开放驳岸", sizeZone: false, sizeZoneNote: "五环内遵守限高规定" },
      fee: "免费",
      openHours: "全天",
      lastVerifiedDate: "2026-11-04",
      daysSinceVerified: 4,
      verifyCount: 37,
      disputeCount: 2,
      closedVotes: 0,
      trustScore: 91,
      status: "verified",
      legalBasisType: "市政河岸开放步道（非朝阳公园封闭管理区）",
      legalBasisWhy: "非公园围栏管理范围，持证牵绳可通行。",
      fieldSignal: "外摆餐厅密集，夜间散步体验好。",
      verifiedPhotos: []
    },
    {
      id: "bj-2",
      city: "beijing",
      name: "朝阳公园（市属公园禁狗对照点）",
      shortName: "朝阳公园 · 禁犬",
      category: "banned_park",
      subType: "普通城市公园 · 严禁携犬入内",
      parkZoneMode: "banned",
      oneLineRule: "朝阳公园围栏门区全面禁狗 · 请仅在北侧亮马河外围活动",
      parkZoneDetail: "红色多边形区域为朝阳公园封闭管理红线，各门区严格禁犬。仅作对照点防止跑空。",
      lat: 39.9412,
      lng: 116.4785,
      address: "朝阳区朝阳公园南路 1 号",
      leashStatus: "banned",
      leashLabel: "禁狗对照点",
      zones: [
        {
          type: "banned",
          label: "朝阳公园禁犬红线区",
          coords: [[39.9465, 116.4700], [39.9465, 116.4860], [39.9340, 116.4860], [39.9340, 116.4700]]
        }
      ],
      facilities: { water: false, waterNote: "禁犬", shade: true, shadeRate: 75, fence: true, fenceNote: "全园禁犬", sizeZone: false, sizeZoneNote: "禁犬" },
      fee: "禁狗对照",
      openHours: "全天禁犬",
      lastVerifiedDate: "2026-11-02",
      daysSinceVerified: 6,
      verifyCount: 51,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 98,
      status: "banned_reference",
      legalBasisType: "《北京市公园条例》",
      legalBasisWhy: "普通公园禁狗对照点。",
      fieldSignal: "门区安检严格。",
      verifiedPhotos: []
    },

    // ================= 上海 =================
    {
      id: "sh-1",
      city: "shanghai",
      name: "徐汇滨江指定萌宠乐园（瑞宁路围栏区）",
      shortName: "徐汇滨江萌宠园",
      category: "pet_park",
      subType: "官方指定宠物公园 · 围栏放绳区 + 滨江牵绳步道",
      parkZoneMode: "dual_zone",
      oneLineRule: "萌宠园围栏内可放绳 · 滨江主步道必牵绳 (≤2m/大犬嘴套)",
      parkZoneDetail: "绿色框为西岸官方萌宠园围栏（分大小犬区可解绳）；琥珀色虚线框为滨江公共步道（必须牵绳 ≤2m，肩高35cm+大型犬须戴嘴套）。",
      lat: 31.1865,
      lng: 121.4598,
      address: "徐汇区瑞宁路与龙腾大道交汇处",
      leashStatus: "fenced_offleash",
      leashLabel: "围栏可放绳",
      zones: [
        {
          type: "offleash",
          label: "西岸萌宠园围栏放绳区",
          coords: [[31.1880, 121.4582], [31.1880, 121.4612], [31.1852, 121.4612], [31.1852, 121.4582]]
        },
        {
          type: "onleash",
          label: "徐汇滨江公共牵绳步道 (≤2m)",
          coords: [[31.1910, 121.4565], [31.1910, 121.4635], [31.1825, 121.4635], [31.1825, 121.4565]]
        }
      ],
      facilities: { water: true, waterNote: "设宠物取水点", shade: true, shadeRate: 55, fence: true, fenceNote: "金属围网+大小犬分区", sizeZone: true, sizeZoneNote: "35cm+大型犬专区" },
      fee: "免费（小程序验犬证预约）",
      openHours: "08:00 - 21:00",
      lastVerifiedDate: "2026-11-06",
      daysSinceVerified: 2,
      verifyCount: 58,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 97,
      status: "verified",
      legalBasisType: "西岸官方指定宠物活动专区",
      legalBasisWhy: "合法指定围栏宠物乐园，入园查验上海电子犬证。",
      fieldSignal: "出铁门到江边草坪必须立刻系好牵引绳。",
      verifiedPhotos: []
    },
    {
      id: "sh-2",
      city: "shanghai",
      name: "世纪公园（市政公园禁狗对照点）",
      shortName: "世纪公园 · 禁犬",
      category: "banned_park",
      subType: "普通城市公园 · 拆围后内部仍禁犬",
      parkZoneMode: "banned",
      oneLineRule: "拆围透绿后内部草坪仍执行禁犬规定（仅外围人行道可走）",
      parkZoneDetail: "经 44 位持证狗友现场核实：小红书旧帖称拆围后可进狗系误传，内部红线区严禁犬只入内。",
      lat: 31.2165,
      lng: 121.5518,
      address: "浦东新区锦绣路 1001 号",
      leashStatus: "banned",
      leashLabel: "禁狗对照点",
      zones: [
        {
          type: "banned",
          label: "世纪公园内部禁犬红线区",
          coords: [[31.2240, 121.5420], [31.2240, 121.5610], [31.2090, 121.5610], [31.2090, 121.5420]]
        }
      ],
      facilities: { water: false, waterNote: "禁犬", shade: true, shadeRate: 80, fence: false, fenceNote: "全园禁犬", sizeZone: false, sizeZoneNote: "禁犬" },
      fee: "禁狗对照",
      openHours: "全天禁犬",
      lastVerifiedDate: "2026-11-03",
      daysSinceVerified: 5,
      verifyCount: 44,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 98,
      status: "banned_reference",
      legalBasisType: "《上海市公园管理条例》",
      legalBasisWhy: "普通公园禁狗对照点。",
      fieldSignal: "保安巡逻高频劝返。",
      verifiedPhotos: []
    },

    // ================= 广州 =================
    {
      id: "gz-1",
      city: "guangzhou",
      name: "琶洲大桥北侧江岸非公园市政草坡",
      shortName: "琶洲北江岸草坡",
      category: "non_park_green",
      subType: "河岸市政绿地 · 非公园红线区",
      parkZoneMode: "onleash_only",
      oneLineRule: "非公告禁犬公园范围 · 全程必须牵绳 (≤1.5m)",
      parkZoneDetail: "位于临江带状公园封闭区外侧，属市政沿江开放绿化带，持广州电子犬证牵绳合规。",
      lat: 23.1128,
      lng: 113.3685,
      address: "天河区员村临江大道东段北桥头外侧",
      leashStatus: "onleash_required",
      leashLabel: "必须牵绳 ≤1.5m",
      zones: [
        {
          type: "onleash",
          label: "沿江非公园市政牵绳区",
          coords: [[23.1145, 113.3650], [23.1145, 113.3720], [23.1112, 113.3720], [23.1112, 113.3650]]
        }
      ],
      facilities: { water: false, waterNote: "需自备水", shade: true, shadeRate: 72, fence: false, fenceNote: "开放江岸", sizeZone: false, sizeZoneNote: "无分区" },
      fee: "免费",
      openHours: "全天（建议晚间前往）",
      lastVerifiedDate: "2026-11-05",
      daysSinceVerified: 3,
      verifyCount: 23,
      disputeCount: 1,
      closedVotes: 0,
      trustScore: 88,
      status: "verified",
      legalBasisType: "市政道路沿江开放绿化带",
      legalBasisWhy: "不在政府公告禁犬市政公园名录内。",
      fieldSignal: "榕树遮阴大，江风凉爽。",
      verifiedPhotos: []
    },

    // ================= 杭州 =================
    {
      id: "hz-1",
      city: "hangzhou",
      name: "闻涛路最美跑道外侧市政河岸绿带",
      shortName: "闻涛路河岸绿带",
      category: "non_park_green",
      subType: "河岸市政绿道 · 非西湖名胜公园区",
      parkZoneMode: "onleash_only",
      oneLineRule: "钱塘江南岸开放市政绿道 · 全程牵绳 (≤1.5m)",
      parkZoneDetail: "滨江区市政开放沿江步道，多处设文明养犬拾便箱，按杭州市规定出户时段牵绳通行。",
      lat: 30.2215,
      lng: 120.2148,
      address: "滨江区闻涛路钱塘江南岸步道",
      leashStatus: "onleash_required",
      leashLabel: "必须牵绳 ≤1.5m",
      zones: [
        {
          type: "onleash",
          label: "钱塘江南岸市政牵绳绿道",
          coords: [[30.2235, 120.2110], [30.2235, 120.2190], [30.2195, 120.2190], [30.2195, 120.2110]]
        }
      ],
      facilities: { water: true, waterNote: "驿站外侧可接水", shade: true, shadeRate: 60, fence: false, fenceNote: "江堤有护栏", sizeZone: false, sizeZoneNote: "无分区" },
      fee: "免费",
      openHours: "按杭州规定出户时段",
      lastVerifiedDate: "2026-11-04",
      daysSinceVerified: 4,
      verifyCount: 27,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 92,
      status: "verified",
      legalBasisType: "钱塘江沿江市政绿道",
      legalBasisWhy: "非封闭市政公园，配套拾便箱完善。",
      fieldSignal: "注意避让骑行道。",
      verifiedPhotos: []
    },

    // ================= 成都 =================
    {
      id: "cd-1",
      city: "chengdu",
      name: "麓湖生态城·毛孩子友好岛",
      shortName: "麓湖友好岛",
      category: "pet_park",
      subType: "社区指定宠物友好公园 · 围栏放绳草坪 + 街区牵绳步道",
      parkZoneMode: "dual_zone",
      oneLineRule: "专属围栏草坪可放绳 · 商业步道与渡轮必牵绳",
      parkZoneDetail: "绿色实线框为双门围栏释放草坪（可放绳）；琥珀色虚线框为岛上餐饮街区与码头（必须全程牵绳）。",
      lat: 30.4682,
      lng: 104.0695,
      address: "天府新区麓湖生态城艺展中心旁",
      leashStatus: "fenced_offleash",
      leashLabel: "围栏可放绳",
      zones: [
        {
          type: "offleash",
          label: "麓湖专属围栏放绳草坪",
          coords: [[30.4698, 104.0680], [30.4698, 104.0710], [30.4668, 104.0710], [30.4668, 104.0680]]
        },
        {
          type: "onleash",
          label: "岛上商业步道牵绳区",
          coords: [[30.4718, 104.0660], [30.4718, 104.0730], [30.4648, 104.0730], [30.4648, 104.0660]]
        }
      ],
      facilities: { water: true, waterNote: "多处宠物饮水台与冲脚池", shade: true, shadeRate: 76, fence: true, fenceNote: "木质围栏+双重门", sizeZone: true, sizeZoneNote: "分时段大小犬活动" },
      fee: "免费",
      openHours: "09:00 - 21:30",
      lastVerifiedDate: "2026-11-06",
      daysSinceVerified: 2,
      verifyCount: 49,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 97,
      status: "verified",
      legalBasisType: "社区官方规划宠物主题绿地",
      legalBasisWhy: "成都标杆级宠物友好示范区。",
      fieldSignal: "全岛餐厅外摆均支持带狗。",
      verifiedPhotos: []
    },

    // ================= 香港 (Phase 2 候选示范) =================
    {
      id: "hk-1",
      city: "hongkong",
      name: "蝴蝶谷道宠物公园 (Pet Garden)",
      shortName: "蝴蝶谷宠物公园",
      category: "pet_park",
      subType: "康文署 55 个专属宠物公园之一 · 双重闸门围栏放绳",
      parkZoneMode: "fenced_offleash",
      oneLineRule: "康文署专属【宠物公园】· 双重闸门围栏内可合法放绳",
      parkZoneDetail: "绿色实线区为康文署专属 Pet Garden（围栏内可解绳，4类格斗犬除外），切勿与「宠物共享公园」混淆。",
      lat: 22.3412,
      lng: 114.1458,
      address: "九龙深水埗蝴蝶谷道 2 号 (data.gov.hk)",
      leashStatus: "fenced_offleash",
      leashLabel: "围栏可放绳",
      zones: [
        {
          type: "offleash",
          label: "康文署蝴蝶谷宠物公园围栏放绳区",
          coords: [[22.3435, 114.1435], [22.3435, 114.1480], [22.3390, 114.1480], [22.3390, 114.1435]]
        }
      ],
      facilities: { water: true, waterNote: "康文署宠物饮水机+冲身设施", shade: true, shadeRate: 62, fence: true, fenceNote: "双重防走失闸门", sizeZone: true, sizeZoneNote: "分设大/小型狗区" },
      fee: "免费",
      openHours: "07:00 - 24:00",
      lastVerifiedDate: "2026-11-06",
      daysSinceVerified: 2,
      verifyCount: 53,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 98,
      status: "verified",
      legalBasisType: "康文署指定宠物公园 (data.gov.hk)",
      legalBasisWhy: "属康文署 55 个专属宠物公园之一，围栏内豁免公众地方牵绳限制。",
      fieldSignal: "设施极佳，有敏捷训练跳栏。",
      verifiedPhotos: []
    },
    {
      id: "hk-2",
      city: "hongkong",
      name: "维多利亚公园（康文署宠物共享公园）",
      shortName: "维园 · 共享牵绳",
      category: "pet_park",
      subType: "康文署 180 个【宠物共享公园】之一 · 严禁放绳！",
      parkZoneMode: "shared_onleash",
      oneLineRule: "【宠物共享公园】≠ 宠物公园 · 全程必系狗带 (≥20kg 限2m)",
      parkZoneDetail: "琥珀色虚线框为维园共享区：与市民共用场地，无独立宠物围栏，必须全程系狗带，违例放绳最高罚 HK$50,000！",
      lat: 22.2825,
      lng: 114.1888,
      address: "铜锣湾兴发街 1 号 (data.gov.hk)",
      leashStatus: "onleash_required",
      leashLabel: "共享区·严禁放绳",
      zones: [
        {
          type: "onleash",
          label: "康文署宠物共享公园（必须全程牵绳 ≤2m）",
          coords: [[22.2860, 114.1850], [22.2860, 114.1925], [22.2790, 114.1925], [22.2790, 114.1850]]
        }
      ],
      facilities: { water: true, waterNote: "设狗粪收集箱", shade: true, shadeRate: 75, fence: false, fenceNote: "无独立宠物围栏！与市民共用", sizeZone: false, sizeZoneNote: "≥20kg狗带≤2米" },
      fee: "免费",
      openHours: "全天开放",
      lastVerifiedDate: "2026-11-05",
      daysSinceVerified: 3,
      verifyCount: 39,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 94,
      status: "verified",
      legalBasisType: "康文署「宠物共享公园」+ Cap. 167D",
      legalBasisWhy: "系统强区分示范：共享公园严禁解绳奔跑。",
      fieldSignal: "康文署职员常驻巡查狗带与清洁（不清狗粪定额罚 HK$3,000）。",
      verifiedPhotos: []
    },
    {
      id: "hk-3",
      city: "hongkong",
      name: "The Doghouse Bistro (西贡持牌露天座餐厅)",
      shortName: "Doghouse 餐厅",
      category: "pet_merchant",
      subType: "食环署持牌露天座可带狗餐厅（约1,000间示范）",
      parkZoneMode: "onleash_only",
      oneLineRule: "持牌露天座合法携犬 · 全体型友好 · 室内厨房禁入",
      parkZoneDetail: "符合香港食环署 Cap. 132X 规例：获批露天海景座位区可合法携犬就餐，中大型唐狗/金毛均欢迎。",
      lat: 22.3815,
      lng: 114.2735,
      address: "西贡万年街海傍广场地下",
      merchantRules: {
        allowIndoor: "仅限持牌露天海景座位区（符合食环署规例）",
        sizeLimit: "全体型友好",
        leashReq: "需系狗带固定于桌旁"
      },
      leashStatus: "onleash_required",
      leashLabel: "露天座·需牵绳",
      zones: [
        {
          type: "offleash",
          label: "持牌露天宠物友善餐饮区",
          coords: [[22.3828, 114.2720], [22.3828, 114.2750], [22.3802, 114.2750], [22.3802, 114.2720]]
        }
      ],
      facilities: { water: true, waterNote: "独立不锈钢水盆", shade: true, shadeRate: 85, fence: true, fenceNote: "外摆护栏+遮阳蓬", sizeZone: false, sizeZoneNote: "大型犬友好" },
      fee: "人均 HK$140",
      openHours: "08:30 - 22:00",
      lastVerifiedDate: "2026-11-04",
      daysSinceVerified: 4,
      verifyCount: 29,
      disputeCount: 0,
      closedVotes: 0,
      trustScore: 93,
      status: "verified",
      legalBasisType: "香港食环署批准露天座位之持牌食肆",
      legalBasisWhy: "获批露天座位区域可合法携犬就餐。",
      fieldSignal: "海风凉爽，提供狗狗专属鲜食。",
      verifiedPhotos: []
    }
  ],

  // 6.5 投毒 / 危险预警（带地图警戒半径 radiusMeters）
  alerts: [
    {
      id: "alert-sz-1",
      city: "shenzhen",
      title: "侨城东路北侧灌木丛发现疑似异烟肼染色肉肠",
      hazardType: "剧毒饵料",
      locationText: "福田区侨城东路与深南大道交界东北角灌木根部",
      lat: 22.5365,
      lng: 114.0068,
      radiusMeters: 450,
      reportedAt: "2小时前",
      hoursAgo: 2.3,
      ttlHours: 72,
      confirmCount: 4,
      requiredConfirm: 3,
      status: "confirmed",
      reporter: "边牧闪电爸 (深A·88492)",
      confirmpLogs: [
        "00:45 边牧闪电爸 (深A·88492) 首发实拍上报",
        "01:02 柴犬花生妈 (深A·30192) 到场交叉确认",
        "01:18 金毛麦子 (深B·66102) 到场交叉确认（已封存样本报警）",
        "01:40 萨摩耶雪球 (深A·91204) 交叉确认现场已拉警戒线"
      ],
      note: "散落于绿化带内侧约 3 处，请周边狗友严禁让狗狗低头嗅闻草丛，建议佩戴防暴食嘴套。"
    },
    {
      id: "alert-sz-2",
      city: "shenzhen",
      title: "后海中心河东岸草坪发现碎玻璃渣与铁丝",
      hazardType: "物理利器",
      locationText: "南山区中心路后海河东岸木栈道北端草坪",
      lat: 22.5128,
      lng: 113.9385,
      radiusMeters: 300,
      reportedAt: "50分钟前",
      hoursAgo: 0.9,
      ttlHours: 48,
      confirmCount: 2,
      requiredConfirm: 3,
      status: "pending",
      reporter: "柯基煤球 (深A·44109)",
      confirmpLogs: [
        "02:10 柯基煤球 (深A·44109) 首发实拍上报",
        "02:35 法斗猪猪 (深A·51908) 到场交叉确认（再需 1 人确认即激活全城地图红圈警报）"
      ],
      note: "草丛内有装修遗留碎玻璃片。目前 2/3 人确认，附近持证狗友可协助第 3 票交叉核实。"
    },
    {
      id: "alert-sz-3",
      city: "shenzhen",
      title: "新洲河绿道中段红火蚁巢（水务物业已完成消杀）",
      hazardType: "生物危险",
      locationText: "福田区新洲同创汇东侧河岸草坡",
      lat: 22.5290,
      lng: 114.0480,
      radiusMeters: 250,
      reportedAt: "2天前",
      hoursAgo: 58,
      ttlHours: 72,
      confirmCount: 5,
      requiredConfirm: 3,
      status: "resolved",
      reporter: "贵宾可乐 (深A·21904)",
      confirmpLogs: [
        "5位持证用户完成交叉确认 → 管养单位已投药消杀并插旗标示，状态转为【已处理】"
      ],
      note: "已完成消杀，经过时走硬化步道即可。"
    },
    {
      id: "alert-sz-4",
      city: "shenzhen",
      title: "香蜜湖外围行道树坑白色粉末（已核实为园林防虫生石灰）",
      hazardType: "误报澄清",
      locationText: "福田区农园路西侧行道树树坑",
      lat: 22.5460,
      lng: 114.0220,
      radiusMeters: 200,
      reportedAt: "1天前",
      hoursAgo: 42,
      ttlHours: 72,
      confirmCount: 3,
      requiredConfirm: 3,
      status: "debunked",
      reporter: "雪纳瑞豆豆 (深A·80112)",
      confirmpLogs: [
        "3位持证狗友现场核实施工单，证实为常规树木刷白生石灰，状态标记为【已辟谣】"
      ],
      note: "系秋季行道树正常防虫刷白作业，非投毒。"
    },
    {
      id: "alert-hk-1",
      city: "hongkong",
      title: "湾仔半山宝云道斜坡发现疑似毒饵（警方及爱协已立牌）",
      hazardType: "剧毒饵料",
      locationText: "香港岛湾仔半山宝云道近司徒拔道交界斜坡",
      lat: 22.2718,
      lng: 114.1725,
      radiusMeters: 500,
      reportedAt: "7小时前",
      hoursAgo: 7.5,
      ttlHours: 72,
      confirmCount: 6,
      requiredConfirm: 3,
      status: "confirmed",
      reporter: "唐狗阿黄 (HK·AFCD·99281)",
      confirmpLogs: [
        "6位香港持牌狗主交叉拍照确认，SPCA 爱护动物协会巡查车已到场"
      ],
      note: "宝云道属历史毒狗高危路段，请全程短绳（≤1.5m）并佩戴防食网罩。"
    }
  ],

  licensePresets: {
    compliant_corgi: {
      dogName: "闪电",
      breed: "威尔士柯基犬",
      weightKg: 12.5,
      ageYears: 3,
      isBrachycephalic: false,
      licenseNo: "粤B·SZ2026-88492",
      validUntil: "2027-10-31",
      ownerName: "林*然",
      issueCity: "shenzhen",
      faceMatchScore: 94
    },
    large_golden: {
      dogName: "麦子",
      breed: "金毛寻回犬",
      weightKg: 31.0,
      ageYears: 5,
      isBrachycephalic: false,
      licenseNo: "HK-AFCD-40912",
      validUntil: "2028-05-15",
      ownerName: "陈*文",
      issueCity: "hongkong",
      faceMatchScore: 91
    },
    french_bulldog: {
      dogName: "煤球",
      breed: "法国斗牛犬 (短鼻犬)",
      weightKg: 11.2,
      ageYears: 4,
      isBrachycephalic: true,
      licenseNo: "沪A·SH2026-31094",
      validUntil: "2027-08-20",
      ownerName: "周*宁",
      issueCity: "shanghai",
      faceMatchScore: 89
    },
    banned_pitbull_test: {
      dogName: "雷霆",
      breed: "比特斗牛梗 (Pit Bull)",
      weightKg: 24.0,
      ageYears: 2,
      isBrachycephalic: false,
      licenseNo: "待核验-00000",
      validUntil: "2027-01-01",
      ownerName: "测试用户",
      issueCity: "shenzhen",
      faceMatchScore: 86
    }
  }
};
