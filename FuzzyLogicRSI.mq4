//+------------------------------------------------------------------+
//|                                                FuzzyLogicRSI.mq4 |
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
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
input int FuzzRange = 1;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int cnt;
   int CurrentPosition = -1;
   
   int order_select;
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   
   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {
     int rsi = FuzzyLogicRSI();
     int breakout = BreakOut(24);
     if(rsi == 1 && iClose(NULL,0,0) < iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,0))
     {
        OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(500*Point),0, "Buy", 0, 0, Blue);
     }    
     
     if(rsi == 2 && iClose(NULL,0,0) > iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,0))
     {
        OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(500*Point),0, "Sella", 0, 0, Blue);
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
       if(FuzzyLogicRSI() == 2)
          OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
     }
     //売りポジションだった場合
     if(OrderType()==OP_SELL)
     {
        if(FuzzyLogicRSI() == 1)
           OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
     }
    }
  }
//+------------------------------------------------------------------+
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
    if(irsi <= 20)
    {
      //irsiがold_RSIよりも小さかったらold_RSIを更新
      if(irsi <= old_RSI)
      {
         old_RSI = irsi;
      }
      //irsiがold_RSIよりも大きかったら決済シグナル
      if(irsi > old_RSI + FuzzRange)
      {
         //初期化
         old_RSI = 50;
      
         //売りポジション決済
         return(1);
      }
    }
    //irsiが70以上のときにファジー処理開始
    if(80 <= irsi)
    {
      //irsiがold_RSIよりも大きかったらold_RSIを更新
      if(old_RSI <= irsi)
      {
         old_RSI = irsi;
      }
      //irsiがold_RSIよりも小さかったら決済シグナル
      if(old_RSI > irsi + FuzzRange)
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