import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() => runApp(
  ChangeNotifierProvider(create: (_) => GameState(), child: const MyApp()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '华科重生模拟器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SimSun',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: const Scaffold(body: GameScreen()),
    );
  }
}

enum AttributeType { score, stress, luck, roommateRelation }

class GameState with ChangeNotifier {
  int _score = 60;
  int _stress = 20;
  int _luck = 5;
  int _roommateRelation = 50;
  String _currentEvent = "欢迎来到华中科技大学！";
  final List<String> _history = [];
  bool _isEnding = false;
  String _endingType = "";
  final Random _random = Random();

  GameState() {
    // 添加初始化事件触发
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerNewEvent());
  }

  final List<Map<String, dynamic>> _events = [
    {
      'desc': '凌晨三点，你发现室友在偷偷卷代码，你要：',
      'weight': 1.5,
      'options': [
        {
          'text': '加入内卷',
          'effect': {AttributeType.score: 5, AttributeType.stress: 10},
        },
        {
          'text': '举报给辅导员',
          'effect': {
            AttributeType.roommateRelation: -20,
            AttributeType.luck: 5,
          },
        },
        {
          'text': '继续打游戏',
          'effect': {AttributeType.stress: -5, AttributeType.score: -3},
        },
      ],
    },
    {
      'desc': '东九湖的鸭子拦路讨食，你要：',
      'options': [
        {
          'text': '投喂喻家山特产',
          'effect': {AttributeType.luck: 10},
        },
        {
          'text': '拍照发HUB系统',
          'effect': {AttributeType.score: 2},
        },
        {
          'text': '假装没看见',
          'effect': {AttributeType.stress: 5},
        },
      ],
    },
    {
      'desc': '在绝望坡骑自行车时遇到陡坡，你要：',
      'weight': 0.8,
      'options': [
        {
          'text': '全力冲刺',
          'effect': {AttributeType.stress: 8, AttributeType.luck: 3},
        },
        {
          'text': '下车推行',
          'effect': {AttributeType.stress: -2},
        },
        {
          'text': '拍照发朋友圈',
          'effect': {AttributeType.roommateRelation: 5},
        },
      ],
    },
    {
      'desc': '微积分考试临近，你的复习策略是：',
      'weight': 2.0,
      'options': [
        {
          'text': '通宵刷题',
          'effect': {AttributeType.score: 8, AttributeType.stress: 15},
        },
        {
          'text': '抱学霸大腿',
          'effect': {
            AttributeType.roommateRelation: -10,
            AttributeType.score: 5,
          },
        },
        {
          'text': '转发杨叔保佑',
          'effect': {AttributeType.luck: 10, AttributeType.score: -3},
        },
      ],
    },
    {
      'desc': '韵苑食堂推出新菜品，你要：',
      'options': [
        {
          'text': '勇当试吃先锋',
          'effect': {AttributeType.luck: -5, AttributeType.stress: -8},
        },
        {
          'text': '拍照发表白墙',
          'effect': {AttributeType.roommateRelation: 5},
        },
        {
          'text': '坚持吃热干面',
          'effect': {AttributeType.stress: -3},
        },
      ],
    },
    {
      'desc': 'HUB系统突然崩溃，你的反应：',
      'options': [
        {
          'text': '疯狂刷新页面',
          'effect': {AttributeType.stress: 10},
        },
        {
          'text': '去梧桐雨买咖啡',
          'effect': {AttributeType.stress: -5},
        },
        {
          'text': '在群里发表情包',
          'effect': {AttributeType.roommateRelation: 5},
        },
      ],
    },
    {
      'desc': '在醉晚亭听到笛箫合奏，你要：',
      'weight': 0.7,
      'options': [
        {
          'text': '加入民乐团',
          'effect': {AttributeType.score: -2, AttributeType.luck: 8},
        },
        {
          'text': '录视频发抖音',
          'effect': {AttributeType.luck: 5},
        },
        {
          'text': '继续背单词',
          'effect': {AttributeType.score: 3},
        },
      ],
    },
    {
      'desc': '校庆开放日遇到迷路游客，你要：',
      'options': [
        {
          'text': '热情指路',
          'effect': {AttributeType.luck: 8},
        },
        {
          'text': '推销校园卡',
          'effect': {AttributeType.score: 5},
        },
        {
          'text': '假装没看见',
          'effect': {AttributeType.stress: 3},
        },
      ],
    },
    {
      'desc': '在图书馆发现空座位，但旁边是情侣，你要：',
      'weight': 1.2,
      'options': [
        {
          'text': '硬着头皮坐下',
          'effect': {AttributeType.stress: 10},
        },
        {
          'text': '换到西十二',
          'effect': {AttributeType.score: 5},
        },
        {
          'text': '回宿舍开黑',
          'effect': {AttributeType.score: -5},
        },
      ],
    },
    {
      'desc': '百团大战招新日，你要：',
      'options': [
        {
          'text': '加入联创团队',
          'effect': {AttributeType.score: 10},
        },
        {
          'text': '报名街舞社',
          'effect': {AttributeType.stress: -8},
        },
        {
          'text': '围观机器人比赛',
          'effect': {AttributeType.luck: 5},
        },
      ],
    },
    {
      'desc': '梧桐语问学中心开放预约，你要：',
      'options': [
        {
          'text': '抢研讨室',
          'effect': {AttributeType.score: 5},
        },
        {
          'text': '参加茶话会',
          'effect': {AttributeType.roommateRelation: 10},
        },
        {
          'text': '去咖啡厅摸鱼',
          'effect': {AttributeType.stress: -5},
        },
      ],
    },
    {
      'desc': '喻园大道突降暴雨，你要：',
      'weight': 0.9,
      'options': [
        {
          'text': '雨中狂奔',
          'effect': {AttributeType.stress: 5},
        },
        {
          'text': '便利店买伞',
          'effect': {AttributeType.luck: -3},
        },
        {
          'text': '等校车救援',
          'effect': {AttributeType.score: -2},
        },
      ],
    },
    {
      'desc': '发现校园卡丢失，你要：',
      'options': [
        {
          'text': '挂失补办',
          'effect': {AttributeType.stress: 8},
        },
        {
          'text': '发朋友圈寻卡',
          'effect': {AttributeType.luck: 10},
        },
        {
          'text': '蹭室友的卡',
          'effect': {AttributeType.roommateRelation: -5},
        },
      ],
    },
    {
      'desc': '收到Dian团队面试通知，你要：',
      'weight': 1.3,
      'options': [
        {
          'text': '通宵准备项目',
          'effect': {AttributeType.score: 15, AttributeType.stress: 10},
        },
        {
          'text': '求助学长',
          'effect': {AttributeType.roommateRelation: 8},
        },
        {
          'text': '放弃面试',
          'effect': {AttributeType.stress: -10},
        },
      ],
    },
    {
      'desc': '在青年园遇到猫咪学长，你要：',
      'options': [
        {
          'text': '投喂火腿肠',
          'effect': {AttributeType.luck: 10},
        },
        {
          'text': '拍照发Hub',
          'effect': {AttributeType.roommateRelation: 5},
        },
        {
          'text': '假装没看见',
          'effect': {AttributeType.stress: 3},
        },
      ],
    },
    {
      'desc': '收到挑战杯组队邀请，你要：',
      'weight': 1.4,
      'options': [
        {
          'text': '担任队长',
          'effect': {AttributeType.score: 20, AttributeType.stress: 15},
        },
        {
          'text': '当划水队员',
          'effect': {AttributeType.roommateRelation: -10},
        },
        {
          'text': '拒绝邀请',
          'effect': {AttributeType.stress: -5},
        },
      ],
    },
    {
      'desc': '东九教学楼迷路，你要：',
      'options': [
        {
          'text': '查看导航地图',
          'effect': {AttributeType.score: 2},
        },
        {
          'text': '跟着人群走',
          'effect': {AttributeType.luck: 5},
        },
        {
          'text': '原地等同学',
          'effect': {AttributeType.stress: 3},
        },
      ],
    },
    {
      'desc': '校运会即将开幕，你要：',
      'options': [
        {
          'text': '报名三千米',
          'effect': {AttributeType.stress: 10},
        },
        {
          'text': '当啦啦队员',
          'effect': {AttributeType.roommateRelation: 8},
        },
        {
          'text': '宅在宿舍',
          'effect': {AttributeType.stress: -5},
        },
      ],
    },
    {
      'desc': '实验室仪器突然故障，你要：',
      'weight': 1.1,
      'options': [
        {
          'text': '自己调试',
          'effect': {AttributeType.score: 10},
        },
        {
          'text': '甩锅给师兄',
          'effect': {AttributeType.roommateRelation: -15},
        },
        {
          'text': '假装没看见',
          'effect': {AttributeType.stress: 5},
        },
      ],
    },
    {
      'desc': '看到喻家山夜爬活动，你要：',
      'options': [
        {
          'text': '加入探险队',
          'effect': {AttributeType.luck: 8},
        },
        {
          'text': '举报给保安',
          'effect': {AttributeType.roommateRelation: -10},
        },
        {
          'text': '继续写代码',
          'effect': {AttributeType.score: 5},
        },
      ],
    },
    {
      'desc': '发现校园网限速，你要：',
      'weight': 0.8,
      'options': [
        {
          'text': '投诉网络中心',
          'effect': {AttributeType.stress: 5},
        },
        {
          'text': '蹭室友热点',
          'effect': {AttributeType.roommateRelation: -5},
        },
        {
          'text': '去图书馆',
          'effect': {AttributeType.score: 3},
        },
      ],
    },
    {
      'desc': '遇到华为校招宣讲会，你要：',
      'weight': 1.5,
      'options': [
        {
          'text': '提前占座',
          'effect': {AttributeType.score: 10},
        },
        {
          'text': '帮忙发传单',
          'effect': {AttributeType.luck: 5},
        },
        {
          'text': '继续打游戏',
          'effect': {AttributeType.stress: -5},
        },
      ],
    },
    {
      'desc': '宿舍出现蟑螂，你要：',
      'options': [
        {
          'text': '用拖鞋拍死',
          'effect': {AttributeType.stress: -5},
        },
        {
          'text': '尖叫逃跑',
          'effect': {AttributeType.stress: 8},
        },
        {
          'text': '买杀虫剂',
          'effect': {AttributeType.luck: 3},
        },
      ],
    },
    {
      'desc': '收到晨跑打卡通知，你要：',
      'weight': 1.2,
      'options': [
        {
          'text': '六点起床',
          'effect': {AttributeType.score: 5},
        },
        {
          'text': '找代跑',
          'effect': {AttributeType.luck: -10},
        },
        {
          'text': '直接翘掉',
          'effect': {AttributeType.stress: 3},
        },
      ],
    },
    {
      'desc': '在集贸买水果被坑，你要：',
      'options': [
        {
          'text': '据理力争',
          'effect': {AttributeType.stress: 5},
        },
        {
          'text': '发树洞吐槽',
          'effect': {AttributeType.roommateRelation: 8},
        },
        {
          'text': '自认倒霉',
          'effect': {AttributeType.luck: -3},
        },
      ],
    },
    {
      'desc': '看到光谷体育馆演唱会海报，你要：',
      'weight': 0.7,
      'options': [
        {
          'text': '排队抢票',
          'effect': {AttributeType.stress: 10},
        },
        {
          'text': '当黄牛',
          'effect': {AttributeType.luck: -15},
        },
        {
          'text': '在宿舍看直播',
          'effect': {AttributeType.stress: -5},
        },
      ],
    },
    {
      'desc': '课程设计遇到猪队友，你要：',
      'weight': 1.6,
      'options': [
        {
          'text': '自己全包',
          'effect': {AttributeType.score: 10, AttributeType.stress: 15},
        },
        {
          'text': '找老师举报',
          'effect': {AttributeType.roommateRelation: -20},
        },
        {
          'text': '一起摆烂',
          'effect': {AttributeType.score: -10},
        },
      ],
    },
    {
      'desc': '发现校车排队过长，你要：',
      'options': [
        {
          'text': '挤下一班',
          'effect': {AttributeType.stress: 5},
        },
        {
          'text': '骑共享单车',
          'effect': {AttributeType.luck: 3},
        },
        {
          'text': '直接翘课',
          'effect': {AttributeType.score: -5},
        },
      ],
    },
    {
      'desc': '在爱因斯坦广场看到无人机表演，你要：',
      'options': [
        {
          'text': '加入航模社',
          'effect': {AttributeType.score: 8},
        },
        {
          'text': '直播赚打赏',
          'effect': {AttributeType.luck: 10},
        },
        {
          'text': '回实验室',
          'effect': {AttributeType.stress: -5},
        },
      ],
    },
    {
      'desc': '宿舍空调突然断电，你要：',
      'weight': 0.9,
      'options': [
        {
          'text': '报修宿管',
          'effect': {AttributeType.stress: 5},
        },
        {
          'text': '偷接线路',
          'effect': {AttributeType.luck: -10},
        },
        {
          'text': '去图书馆蹭空调',
          'effect': {AttributeType.score: 3},
        },
      ],
    },
    {
      'desc': '看到学在华中大标语，你要：',
      'options': [
        {
          'text': '拍给家长看',
          'effect': {AttributeType.stress: -3},
        },
        {
          'text': '发朋友圈吐槽',
          'effect': {AttributeType.roommateRelation: 5},
        },
        {
          'text': '继续打游戏',
          'effect': {AttributeType.score: -2},
        },
      ],
    },
    {
      'desc': '遇到校领导听课，你要：',
      'weight': 1.3,
      'options': [
        {
          'text': '积极发言',
          'effect': {AttributeType.score: 10},
        },
        {
          'text': '低头装死',
          'effect': {AttributeType.stress: 5},
        },
        {
          'text': '假装去厕所',
          'effect': {AttributeType.luck: -5},
        },
      ],
    },
    {
      'desc': '发现电动车被偷，你要：',
      'options': [
        {
          'text': '报警处理',
          'effect': {AttributeType.stress: 10},
        },
        {
          'text': '发树洞通缉',
          'effect': {AttributeType.luck: 5},
        },
        {
          'text': '偷别人的车',
          'effect': {AttributeType.roommateRelation: -20},
        },
      ],
    },
    {
      'desc': '在喻园餐厅遇到校长，你要：',
      'weight': 0.6,
      'options': [
        {
          'text': '上前合影',
          'effect': {AttributeType.luck: 15},
        },
        {
          'text': '默默观察',
          'effect': {AttributeType.stress: -3},
        },
        {
          'text': '发朋友圈直播',
          'effect': {AttributeType.roommateRelation: 8},
        },
      ],
    },
  ];

  void makeChoice(Map<AttributeType, int> effects) {
    if (_isEnding) return;

    _applyEffect(effects);
    _checkEnding();
    _triggerNewEvent();
    notifyListeners();
  }

  void _applyEffect(Map<AttributeType, int> effects) {
    _score = (_score + (effects[AttributeType.score] ?? 0)).clamp(0, 100);
    _stress = (_stress + (effects[AttributeType.stress] ?? 0)).clamp(0, 100);
    _luck = (_luck + (effects[AttributeType.luck] ?? 0)).clamp(0, 100);
    _roommateRelation = (_roommateRelation +
            (effects[AttributeType.roommateRelation] ?? 0))
        .clamp(0, 100);
  }

  void _triggerNewEvent() {
    if (_events.isEmpty) return;

    double totalWeight = _events.fold(
      0.0,
      (sum, e) => sum + (e['weight'] ?? 1.0),
    );
    double randomValue = _random.nextDouble() * totalWeight;

    for (var event in _events) {
      randomValue -= event['weight'] ?? 1.0;
      if (randomValue <= 0) {
        _currentEvent = event['desc'];
        if (!_history.contains(_currentEvent)) {
          _history.add(_currentEvent);
        }
        notifyListeners();
        return;
      }
    }
  }

  void _checkEnding() {
    final conditions = {
      '压力过大退学': _stress >= 100,
      '成功保研！': _score >= 100,
      '欧皇附体': _luck >= 100,
      '众叛亲离': _roommateRelation <= 0,
    };

    conditions.forEach((key, value) {
      if (value && !_isEnding) {
        _endingType = key;
        _isEnding = true;
        notifyListeners();
      }
    });
  }

  void resetGame() {
    _score = 60;
    _stress = 20;
    _luck = 5;
    _roommateRelation = 50;
    _isEnding = false;
    _endingType = "";
    _currentEvent = "开启新人生！";
    _triggerNewEvent(); // 重置时触发新事件
    notifyListeners();
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        image: DecorationImage(
          image: const NetworkImage('https://example.com/hust_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const _StatDisplay(),
                const SizedBox(height: 24),
                Expanded(child: _EventHistory()),
                const SizedBox(height: 24),
                const _EventSection(),
              ],
            ),
          ),
          if (state._isEnding) const _EndingScreen(),
        ],
      ),
    );
  }
}

class _StatDisplay extends StatelessWidget {
  const _StatDisplay();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _StatItem("📖 学分", state._score),
            _StatItem("💢 压力", state._stress, isDanger: state._stress > 80),
            _StatItem("🍀 欧气", state._luck),
            _StatItem("👥 舍友", state._roommateRelation),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final bool isDanger;

  const _StatItem(this.label, this.value, {this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDanger ? Colors.red[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.split(' ')[0], style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$value',
                  key: ValueKey(value),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDanger ? Colors.red : Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.split(' ')[1],
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }
}

class _EventSection extends StatelessWidget {
  const _EventSection();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "当前事件",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              state._currentEvent,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _buildOptions(context, state),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context, GameState state) {
    final currentEvent = state._events.firstWhere(
      (e) => e['desc'] == state._currentEvent,
      orElse: () => {'options': []},
    );

    return (currentEvent['options'] as List).map<Widget>((option) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[50],
          foregroundColor: Colors.blue[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed:
            () => state.makeChoice(
              Map<AttributeType, int>.from(option['effect']),
            ),
        child: Text(option['text']),
      );
    }).toList();
  }
}

class _EventHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "历史记录",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: state._history.length,
                itemBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "▪ ${state._history.reversed.toList()[index]}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndingScreen extends StatelessWidget {
  const _EndingScreen();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GameState>(context);

    return BackdropFilter(
      filter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "👑 人生结局 👑",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                state._endingType,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              _buildOutcomeIllustration(state._endingType),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.replay),
                label: const Text("重新开始人生旅程"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.resetGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutcomeIllustration(String ending) {
    switch (ending) {
      case '成功保研！':
        return const Column(
          children: [
            Icon(Icons.school, size: 48, color: Colors.green),
            Text("你成为了卷王之王！"),
          ],
        );
      case '压力过大退学':
        return const Column(
          children: [
            Icon(Icons.mood_bad, size: 48, color: Colors.red),
            Text("东九湖的鸭子为你送行..."),
          ],
        );
      default:
        return const Icon(Icons.help_outline, size: 48);
    }
  }
}
