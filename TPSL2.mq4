//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()
{
   //変数の宣言
   int cnt, CurrentPosition;
   int Ticket;   
   
   double BuyTP,BuySL;
   double SellTP,SellSL;
   
   
   // オーダーチェック（ポジションなどのデータ）
   CurrentPosition=-1;
   for(cnt=0;cnt < OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS);
   
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }




   // ポジションチェック　ポジション無し
   if(CurrentPosition == -1)
   {   
      //もし終値がMAを上に抜けたら
      if( CrossMA(20) == 1 )      
      {
         //買いポジションを取る  
         Ticket = OrderSend(Symbol(), OP_BUY, 1, Ask, 3, 0, 0, "Buy", 0, 0, Red);
      }  
      
      //もし終値がMAを下に抜けたら
      if( CrossMA(20) == 2)     
      {
         //売りポジションを取る  
         Ticket = OrderSend(Symbol(), OP_SELL, 1, Bid, 3, 0, 0, "Sell", 0, 0, Blue);
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
            if(OrderStopLoss() == NULL || OrderTakeProfit() == NULL)
            {
          
               //TPSLの値を算出
               BuyTP = NormalizeDouble(iBands(NULL,0,10,1,0,PRICE_CLOSE,MODE_UPPER,0),Digits);
               BuySL = NormalizeDouble(iBands(NULL,0,10,1,0,PRICE_CLOSE,MODE_LOWER,0),Digits);
            
               //ストップロス更新
               OrderModify(OrderTicket(), OrderOpenPrice(), BuySL,BuyTP, 0, MediumSeaGreen);
            
            }
         }
         //もし売りポジションだったら
         else if(OrderType()==OP_SELL)
         {
            if(OrderStopLoss() == NULL || OrderTakeProfit() == NULL)
            {
          
               //TPSLの値を算出
               SellTP = NormalizeDouble(iBands(NULL,0,10,1,0,PRICE_CLOSE,MODE_LOWER,0),Digits);
               SellSL = NormalizeDouble(iBands(NULL,0,10,1,0,PRICE_CLOSE,MODE_UPPER,0),Digits);
               
               //ストップロス更新
               OrderModify(OrderTicket(), OrderOpenPrice(), SellSL,SellTP, 0, MediumSeaGreen);
            
            }
         }
      }
            
            
   }
   return(0);
}



/*------------------------------------------------------
関数名   CrossMA
内容     MAとレートのクロスを判断する関数

引数     int Kikan   MAの期間設定
         
戻り値   0:何も出来ていない　1:上抜け
         2:下抜け
-------------------------------------------------------*/
int CrossMA(int Kikan)
{
   double kakoa,gennzaia;
   double kakob,gennzaib;
     

   //一つ前の終値
   kakoa = iClose(NULL,0,1);
   //一つ前のＭＡの値
   kakob = iMA(NULL,0,Kikan,0,0,PRICE_CLOSE,1);

   //現在の終値
   gennzaia = iClose(NULL,0,0);
   //現在のＭＡの値
   gennzaib = iMA(NULL,0,Kikan,0,0,PRICE_CLOSE,0);



   //もし終値がMAを上に抜けたら
   if( kakoa < kakob && gennzaia >= gennzaib)      
   {
      return(1);
   }  
   
   //もし終値がMAを下に抜けたら
   if( kakoa > kakob && gennzaia <= gennzaib)     
   {
      return(2);
   }  


   return(0);
}




// the end.
//+------------------------------------------------------------------+

