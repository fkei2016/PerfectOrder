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
void OnTick()
{

//---
   //変数の宣言
   int cnt;
   int CurrentPosition = -1;
   
   
   double old_fast_ma,old_slow_ma;
   double now_fast_ma,now_slow_ma;
   
   int order_send;
   int oeder_sell;
   int order_select;
   
   int orderhistory_num;
   bool Select_bool;
   int  err_code;
     
   
   
   // オーダーチェック（ポジションなどのデータ）
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }

   //一時間前の２１日線
   old_fast_ma = iMA(NULL,0,21,0,MODE_SMA,PRICE_CLOSE,1);
   //一時間前の９０日線
   old_slow_ma = iMA(NULL,0,90,0,MODE_SMA,PRICE_CLOSE,1);

   //現在の２１日線
   now_fast_ma = iMA(NULL,0,21,0,MODE_SMA,PRICE_CLOSE,0);
   //現在の９０日線
   now_slow_ma = iMA(NULL,0,90,0,MODE_SMA,PRICE_CLOSE,0);
   
   
   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {
      
      //もし２１日線が９０日線を下から上にクロスしたら
      if( old_fast_ma < old_slow_ma && now_fast_ma >= now_slow_ma)      
      {
         //買いポジションを持つ
         order_send = OrderSend(Symbol(), OP_BUY, 3, Ask, 3, Ask-(200*Point), 0, "Buyb", 1, 0, Red);      
      }
      //もし２１日線が９０日線を上から下にクロスしたら
      if( old_fast_ma > old_slow_ma && now_fast_ma <= now_slow_ma)
      {
         //売りポジションを持つ
         oeder_sell =  OrderSend(Symbol(), OP_SELL, 3, Bid, 3, Bid+(200*Point), 0, "Sella", 0, 0, Blue);
      }
      
      
      
     // orderhistory_num = OrdersHistoryTotal();  // アカウント履歴の数を取得
     // check_select_no = orderhistory_num - 1;   // 最新の取引が終了した番号を取得

     // if ( orderhistory_num > 0 && check_select_no < orderhistory_num )
     // {
     //   Select_bool = OrderSelect( check_select_no , SELECT_BY_POS , MODE_HISTORY); // アカウント履歴の任意の注文を選択

     //   if ( Select_bool == true ) 
     //   {
     //       if(OrderProfit() < 0)//損切された場合ドテンする
     //       {
     //         if(OrderMagicNumber() == 0)
     //         {
     //            //OrderSend(Symbol(), OP_SELL, 3, Bid, 3, Bid+(300*Point), Bid-(300*Point), "Sella", 2, 0, Blue);
     //         }
     //         if(OrderMagicNumber() == 1)
     //         {
     //            //OrderSend(Symbol(), OP_BUY, 3, Ask, 3, Ask-(300*Point), Ask+(300*Point), "Buyb", 3, 0, Red);
     //         }
     //       }
     //   } 
     //  else 
     //   {
     //       err_code =  GetLastError(); // エラーコード取得
     //       printf("注文選択エラー:エラーコード[%d]",err_code);
     //   }
     // }
   }
   // ポジション有り
   else 
   { 
     //ポジションの選択
     OrderSelect(CurrentPosition,SELECT_BY_POS);
     //ポジションの確認
     if(OrderSymbol() == Symbol())
     { 
        //もし買いポジションだったら
        if(OrderType()==OP_BUY) 
       {
         //もし２１日線が９０日線を上から下にクロスしたら
         if( old_fast_ma > old_slow_ma && now_fast_ma <= now_slow_ma)
         {
           //手仕舞い
           OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
           //ドテンで売りポジションを取る 
           OrderSend(Symbol(), OP_SELL, 9, Bid, 3, Bid+(200*Point), 0, "Sell", 0, 0, Blue);
         }
       }
        //もし売りポジションだったら
        if(OrderType()==OP_SELL)
       {
         //もし２１日線が９０日線を下から下にクロスしたら
         if( old_fast_ma < old_slow_ma && now_fast_ma >= now_slow_ma)
        {
           //手仕舞い
           OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
           //ドテンで買いポジションを取る 
           OrderSend(Symbol(), OP_BUY, 9, Ask, 3, Ask-(200*Point), 0, "Buy", 1, 0, Red);
         }
        }
      }
   }
  
}
//+------------------------------------------------------------------+
