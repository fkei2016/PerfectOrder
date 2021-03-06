//+------------------------------------------------------------------+
//|                                                   Sample iMA.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
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

int check_select_no; // チェックする注文履歴番号
input double lot = 1;
void OnTick()
{

//---
   //変数の宣言
   int cnt;
   int Position20AND50 = -1;
   int Position20AND100 = -1;
   
   int order_send;
   int oeder_sell;
   int order_select;
   
   int orderhistory_num;
   bool Select_bool;
   int  err_code;
   
   
   int BUY_20AND50 =0;
   int SELL_20AND50 =1;
   int BUY_20AND100 =2;
   int SELL_20AND100 =3;
   
   int MA1 = 21;
   int MA2 = 48;
   int MA3 = 90;
  
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         if(OrderMagicNumber() == BUY_20AND50 ||OrderMagicNumber() == SELL_20AND50)
         {
            Position20AND50 =cnt;
         }
         if(OrderMagicNumber() == BUY_20AND100 ||OrderMagicNumber() == SELL_20AND100)
         {
            Position20AND100 =cnt;
         }

      }
   }
   
   
   // ポジションチェック20AND50　ポジション無し
   if(Position20AND50 == -1)
   {
   
      //もし20日線が50日線を下から上にクロスしたら
      if(CrossMA(MA1,MA2) == 1)      
      {
         //買いポジションを持つ
         order_send = OrderSend(Symbol(), OP_BUY, lot * MoneyManager(), Ask, 3, Ask-(200*Point), 0, "Buyb", BUY_20AND50, 0, Red);      
      }
      //もし20日線が50日線を上から下にクロスしたら
      if(CrossMA(MA1,MA2) == 2)
      {
         //売りポジションを持つ
         oeder_sell =  OrderSend(Symbol(), OP_SELL, lot * MoneyManager(), Bid, 3, Bid+(200*Point), 0, "Sella", SELL_20AND50, 0, Blue);
      }
   }
   // ポジション有り
   else 
   { 
     //ポジションの選択
     OrderSelect(Position20AND50,SELECT_BY_POS);
     //ポジションの確認
     if(OrderSymbol() == Symbol())
     { 
        //もし買いポジションだったら
        if(OrderType() == OP_BUY) 
       {
         //デッドグロスしてたら
         if( CrossMA(MA1,MA2) == 2)
         {
           //手仕舞い
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
           //ドテンで売りポジションを取る 
           //OrderSend(Symbol(), OP_SELL, 3, Bid, 3, Bid+(200*Point), 0, "Sell",SELL_20AND50, 0, Blue);
         }
       }
        //もし売りポジションだったら
        if(OrderType() == OP_SELL)
       {
         //ゴールデンクロスしてたら
         if( CrossMA(MA1,MA2) == 1)
        {
           //手仕舞い
           OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
           //ドテンで買いポジションを取る 
           //OrderSend(Symbol(), OP_BUY, 3, Ask, 3, Ask-(200*Point), 0, "Buy",BUY_20AND50, 0, Red);
        }
       }
      }
   }
   
   
   // ポジションチェック　ポジション無し
   if(Position20AND100 == -1)
   {
   
       //もし20日線が100日線を下から上にクロスしたら
      if(CrossMA(MA1,MA3) == 1)      
      {
         //買いポジションを持つ
         order_send = OrderSend(Symbol(), OP_BUY, lot * MoneyManager(), Ask, 3, Ask-(200*Point), 0, "Buyb", BUY_20AND100, 0, Red);  
      }
      //もし20日線が100日線を上から下にクロスしたら
      if(CrossMA(MA1,MA3) == 2)
      {
         //売りポジションを持つ
         oeder_sell =  OrderSend(Symbol(), OP_SELL, lot * MoneyManager(), Bid, 3, Bid+(200*Point), 0, "Sella", SELL_20AND100, 0, Blue);
      }
   }
   // ポジション有り
   else 
   { 
     //ポジションの選択
     OrderSelect(Position20AND100,SELECT_BY_POS);
     //ポジションの確認
     if(OrderSymbol() == Symbol())
     { 
        //もし買いポジションだったら
        if(OrderType() == OP_BUY) 
       {
         //デッドグロスしてたら
         if( CrossMA(MA1,MA3) == 2)
         {
           //手仕舞い
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
           //ドテンで売りポジションを取る 
           //OrderSend(Symbol(), OP_SELL, 3, Bid, 3, Bid+(200*Point), 0, "Sell",SELL_20AND100, 0, Blue);
         }
       }
        //もし売りポジションだったら
        if(OrderType() == OP_SELL)
       {
         //ゴールデンクロスしてたら
         if( CrossMA(MA1,MA3) == 1)
        {
           //手仕舞い
           OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
           //ドテンで買いポジションを取る 
           //OrderSend(Symbol(), OP_BUY, 3, Ask, 3, Ask-(200*Point), 0, "Buy",BUY_20AND100, 0, Red);
        }
       }
      }
   }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//
//関数名 CrossMA
//
//内容 ゴールデンクロスとデッドクロスを判断する関数
//
//引数 int fast  短期MA
//     int slow  長期MA
//
//戻り値　0:何も発生していない　1:ゴールデンクロス 2:デッドクロス
//+------------------------------------------------------------------+
int CrossMA(int fast, int slow)
{


   double old_fast_ma;
   double old_slow_ma;
   double now_fast_ma;
   double now_slow_ma;
   
   
   //一時間前の短期日線
   old_fast_ma = iMA(NULL,0,fast,0,MODE_SMA,PRICE_CLOSE,1);
   //一時間前の長期日線
   old_slow_ma =iMA(NULL,0,slow,0,MODE_SMA,PRICE_CLOSE,1);
   
   //現在の短期日線
   now_fast_ma = iMA(NULL,0,fast,0,MODE_SMA,PRICE_CLOSE,0);
   //現在の長期日線
   now_slow_ma =iMA(NULL,0,slow,0,MODE_SMA,PRICE_CLOSE,0);
   
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
  blots = AccountBalance() / 10000;

  //小数点第一位までで四捨五入するために、一度１０倍にして、０．５を足して、int型に入れる
  clots = blots * 10 + 0.5;

  //最後に、double型に0.1をかける。
  alots = clots * 0.1 ;
  
  return(alots);
}