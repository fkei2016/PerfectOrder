//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()
{
   //変数の宣言
   int cnt, CurrentPosition;
   int Ticket;   
   double kakoa,gennzaia;
   double kakob,gennzaib;
   
   double old_fast_ma,old_slow_ma;
   double now_fast_ma,now_slow_ma;
     
   // オーダーチェック（ポジションなどのデータ）
   CurrentPosition=-1;
   for(cnt=0;cnt < OrdersTotal();cnt++){
      OrderSelect(cnt,SELECT_BY_POS);
      if(OrderSymbol() == Symbol()) CurrentPosition=cnt;
   }

   //一つ前のＭＡＣＤのメイン
   kakoa = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   //一つ前のＭＡＣＤのシグナル
   kakob = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

   //現在のＭＡＣＤのメイン
   gennzaia = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   //現在のＭＡＣＤのシグナル
   gennzaib = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   
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
      //もしメインがシグナルを下から上にクロスしたら
      if( (kakoa < kakob && gennzaia >= gennzaib) || (old_fast_ma < old_slow_ma && now_fast_ma >= now_slow_ma))      
      {
         //買いポジションを取る  
         Ticket = OrderSend(Symbol(), OP_BUY, 1, Ask, 3, Ask-(200*Point), 0, "Buy", 0, 0, Red);
      }  
      
      //もしメインがシグナルを上から下にクロスしたら
      if( (kakoa > kakob && gennzaia <= gennzaib) || (old_fast_ma > old_slow_ma && now_fast_ma <= now_slow_ma))     
      {
         //売りポジションを取る  
         Ticket = OrderSend(Symbol(), OP_SELL, 1, Bid, 3,  Bid+(200*Point), 0, "Sell", 0, 0, Blue);
      }  
         
           
   
   }
   // ポジション有り
   else 
   {
      
      //ポジションの選択
      OrderSelect(CurrentPosition,SELECT_BY_POS);
      
      //通貨ペアの確認
      if(Symbol() == OrderSymbol())
      {
         //もし買いポジションだったら
         if(OrderType()==OP_BUY)    
         {
            //もしメインがシグナルを上から下にクロスしたら
            if( (kakoa > kakob && gennzaia <= gennzaib) || (old_fast_ma > old_slow_ma && now_fast_ma <= now_slow_ma))
            {
               //手仕舞い
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
            
               //ドテンで売りポジションを取る  
               Ticket = OrderSend(Symbol(), OP_SELL, 1, Bid, 3,  Bid+(200*Point), 0, "Sell", 0, 0, Blue);
            }
      
         }
         //もし売りポジションだったら
         else if(OrderType()==OP_SELL)
         {
            //もしメインがシグナルを下から上にクロスしたら
            if( (kakoa < kakob && gennzaia >= gennzaib) || (old_slow_ma > old_fast_ma && now_slow_ma <= now_fast_ma))      
            {
               //手仕舞い
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
            
               //ドテンで買いポジションを取る  
               Ticket = OrderSend(Symbol(), OP_BUY, 1, Ask, 3,  Ask-(200*Point), 0, "Buy", 0, 0, Red);
            }
         }
      }      
   
      
   }
   return(0);
}






// the end.
//+------------------------------------------------------------------+

