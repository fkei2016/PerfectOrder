//+------------------------------------------------------------------+
//|                                                 PerfectOrder.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   minute = 15;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
  
  input double lot = 1;
  int minute;
void OnTick()
  {
//--- //変数の宣言
   int cnt;
   int CurrentPosition = -1;
   
   int order_select;
   
   int EMA1 = 7;  //移動平均期間 9
   int EMA2 = 14; //移動平均期間 36
   int EMA3 = 21; //移動平均期間 52
   int EMA4 = 48; //移動平均期間 52
   
   
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   double now_ma1;
   double now_ma2;
   double now_ma3;
   double now_ma4;
   
    //4本の移動平均線
   now_ma1 = iMA(NULL,0,EMA1,0,MODE_EMA,PRICE_CLOSE,0);
   now_ma2 = iMA(NULL,0,EMA2,0,MODE_EMA,PRICE_CLOSE,0);
   now_ma3 = iMA(NULL,0,EMA3,0,MODE_EMA,PRICE_CLOSE,0);
   now_ma4 = iMA(NULL,0,EMA4,0,MODE_EMA,PRICE_CLOSE,0);
   
   int abs = MathAbs(minute-Minute());
   int interven = MathAbs((now_ma1*10)-(now_ma4*10));
   
   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1 && abs == 15)
   {
     //買い
     if(((now_ma1 > now_ma2) && (now_ma2 > now_ma3) && (now_ma3 > now_ma4)) == true && interven >= 1)
     {
       OrderSend(Symbol(), OP_BUY, lot * MoneyManager(), Ask, 3, Ask-(750*Point),0, "Buy", 0, 0, Blue);
       minute = Minute();
     }
     //売り
     if(((now_ma1 < now_ma2) && (now_ma2 < now_ma3) &&(now_ma3 < now_ma4)) == true && interven >= 1)
     {
       OrderSend(Symbol() ,OP_SELL, lot * MoneyManager(), Bid, 3,Bid+(750*Point), 0, "Sella", 0, 0, Blue);
       minute = Minute();
     } 
   }
   //ポジションあり
   else
   {
     
     //ポジションの選択
     OrderSelect(CurrentPosition,SELECT_BY_POS);
     //買いポジションだった場合
     if(OrderType()==OP_BUY)
     {
        //パーフェクトオーダー終了
        if(((now_ma1 > now_ma2) && (now_ma2 > now_ma3) &&(now_ma3 > now_ma4)) == false)
        {
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
        }
     }
     //売りポジションだった場合
     if(OrderType()==OP_SELL)
     {
        //パーフェクトオーダー終了
       if(((now_ma1 < now_ma2) && (now_ma2 < now_ma3) &&(now_ma3 < now_ma4)) == false)
       {
          OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
       }
     }
    }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
//関数名 CrossSMA
//
//内容 ゴールデンクロスとデッドクロスを判断する関数
//
//引数 int fast  短期MA
//     int slow  長期MA
//
//戻り値　0:何も発生していない　1:ゴールデンクロス 2:デッドクロス
//+------------------------------------------------------------------+
int CrossSMA(int fast, int slow)
{

   double old_fast_ma;
   double old_slow_ma;
   double now_fast_ma;
   double now_slow_ma;
   
   //一時間前の短期日線
   old_fast_ma = iMA(NULL,0,fast,0,MODE_EMA,PRICE_CLOSE,1);
   //一時間前の長期日線
   old_slow_ma =iMA(NULL,0,slow,0,MODE_EMA,PRICE_CLOSE,1);
   
   //現在の短期日線
   now_fast_ma = iMA(NULL,0,fast,0,MODE_EMA,PRICE_CLOSE,0);
   //現在の長期日線
   now_slow_ma =iMA(NULL,0,slow,0,MODE_EMA,PRICE_CLOSE,0);
   
   //ゴールデンクロス
   if(old_fast_ma<old_slow_ma&&now_fast_ma>=now_slow_ma)
   {
      return(1);
   }
   
   //デッドクロス
   if(old_fast_ma>old_slow_ma&&now_fast_ma<=now_slow_ma)
   {
      return(2);
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//
//関数名 MoneyManager
//
//内容 複利システム（ポジションサイズの計算）
//
//引数 なし
//
//戻り値　lot数
//+------------------------------------------------------------------+
double MoneyManager()
{

  double alots,blots;
  int clots;
  
  //１万ドルが口座にある場合、1ロットが十万通貨なので、１万で割る
  blots = AccountFreeMargin() / 10000;

  //小数点第一位までで四捨五入するために、一度１０倍にして、０．５を足して、int型に入れる
  clots = blots * 10  + 0.5;

  //最後に、double型に0.1をかける。
  alots = clots * 0.1 ;
  
  return(alots);
}

//+------------------------------------------------------------------+
//
//関数名 FuzzyLogicRSI
//
//内容 ファジー理論RSI 決済するべきか判断
//
//引数 なし
//
//戻り値　0 特になし　1 SELL決済　2 BUY決済
//+------------------------------------------------------------------+
int old_RSI = 50;
int FuzzyLogicRSI()
{
    int irsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
    
    //irsiが30以下のときにファジー処理開始
    if(irsi <= 25)
    {
      //irsiがold_RSIよりも小さかったらold_RSIを更新
      if(irsi <= old_RSI)
      {
         old_RSI = irsi;
      }
      //irsiがold_RSIよりも大きかったら決済シグナル
      if(irsi > old_RSI)
      {
         //初期化
         old_RSI = 50;
      
         //売りポジション決済
         return(1);
      }
    }
    //irsiが70以上のときにファジー処理開始
    if(75 <= irsi)
    {
      //irsiがold_RSIよりも大きかったらold_RSIを更新
      if(old_RSI <= irsi)
      {
         old_RSI = irsi;
      }
      //irsiがold_RSIよりも小さかったら決済シグナル
      if(old_RSI > irsi)
      {
         //初期化
         old_RSI = 50;
         
         //買いポジション決済
         return(2);
      }
    }
    
    return(0);
}



//+------------------------------------------------------------------+
//
//関数名 BreakOut
//
//内容 ブレイクアウトシステム
//     過去の時間足の最高値、最安値が更新したら条件成立
//
//引数 何本分の時間足を調べるか
//
//戻り値　0 特になし　1 高値更新　2 安値更新
//+------------------------------------------------------------------+
int BreakOut(int count)
{
   double max,min;
   
   //maxに1個前の時間足の高値のデータを入れる
   max = High[1];
   //minに1個前の時間足の安値のデータを入れる
   min = Low[1];
   
   //過去のデータを調べる
   for(int i= 1; i <= count; i++)
   {
      //maxに入っているレートより、前の時間足のほうが高かったら高値のレートを更新
      if(max < High[i])
        max = High[i];
      
      //minに入っているレートより、前の時間足のほうが低かったら安値のレートを更新
      if(min >Low[i])
        min = Low[i];
   }
   
   //過去のデータよりも現在の高値のほうが高かったら
   if(max < Close[0]) return(1);
   
   //過去のデータよりも現在の安値のほうが安かったら
   if(min > Close[0]) return(2);
   
   
   return(0);
}