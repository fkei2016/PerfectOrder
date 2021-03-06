//+------------------------------------------------------------------+
//|                                                 TBreakSystem.mq4 |
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
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
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
     if(TBreak(400) == 1) OrderSend(Symbol(), OP_BUY , 1, Ask, 3,Ask-(100*Point),Ask+(100*Point), "Buy", 0, 0, Blue);
     
     if(TBreak(400) == 2) OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(100*Point),Bid-(100*Point), "Sella", 0, 0, Blue);
   }
   //ポジションあり
   else
   {
     //ポジションの選択
     OrderSelect(CurrentPosition,SELECT_BY_POS);
     //買いポジションだった場合
     if(OrderType()==OP_BUY)
     {
       
     }
     //売りポジションだった場合
     if(OrderType()==OP_SELL)
     {
        
     }
    }
   
 }
//+------------------------------------------------------------------+

/*-------------------------------------------------------------------
変数名　 TBreak
引数　 count 何本文の時間足を調べるか?

概要
過去n本文の時間足の最高値、もしくは最安値が更新したら条件成立。

戻り値　１なら買いの条件　2なら売りの条件　0は条件不成立
-------------------------------------------------------------------*/
int TBreak(int count)
{
     double max,min;
     max = High[1];
     min = Low[1];
  
     for(int i =1; i < count; i++)
     {
        if(max < High[i])
        {
           max = High[i];
        }
        
        if(min > Low[i])
        {
           min = Low[i];
        }
     }
     
     if(max < Close[0]) return(1);
     
     if(min > Close[0]) return(2);
     
     return(0);
}
