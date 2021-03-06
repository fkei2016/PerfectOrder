//+------------------------------------------------------------------+
//|                                                      zigfibo.mq4 |
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
   time = 999;
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
  int time;
  double old_pos =0.0f;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int CurrentPosition = -1;
   
   int order_select;
   
    // オーダーチェック（ポジションなどのデータ）
   for(int cnt=0;cnt<OrdersTotal();cnt++)
   {
      order_select = OrderSelect(cnt,SELECT_BY_POS);
      
      if(OrderSymbol() == Symbol()) 
      {
         CurrentPosition=cnt;
      }
   }
   
   if(MathAbs(time - Minute()) >= 15)
   {
      //ZigZagの頂点と線を引く
      int depth=12;
      int Deviation=5;
      int Backstep=3;

      double zzArray[6];
      int i=0, zzCounter=0;
      
      datetime old_time[6];
      
      while(i<500 && zzCounter<6)
      {
         double zzPoint=iCustom(Symbol(), 0, "ZigZag", depth, Deviation, Backstep, 0, i);
  
         if(zzPoint!=0)
         {
            zzArray[zzCounter]=zzPoint;
            old_time[zzCounter] = Time[i];
            zzCounter++;
         }

            i++;
      }
         
      string obj_name = "testobj";
      int    chart_id = 0;
      
      //ObjectsDeleteAll();                                                // オブジェクト全削除

      ObjectCreate(obj_name,                                     // オブジェクト作成
                    OBJ_EXPANSION,                                             // オブジェクトタイプ
                    0,                                                       // サブウインドウ番号
                    old_time[3],                                               // 1番目の時間のアンカーポイント
                    zzArray[3],                                              // 1番目の価格のアンカーポイント
                    old_time[2],                                               // 2番目の時間のアンカーポイント
                    zzArray[2],                                              // 2番目の価格のアンカーポイント
                    old_time[1],                                               // 3番目の時間のアンカーポイント
                    zzArray[1]                                               // 3番目の価格のアンカーポイント
                    );
    
      ObjectSetInteger(chart_id,obj_name,OBJPROP_COLOR,clrYellow);    // ラインの色設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_STYLE,STYLE_SOLID);  // ラインのスタイル設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_WIDTH,1);              // ラインの幅設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTABLE,true);     // オブジェクトの選択可否設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_SELECTED,true);       // オブジェクトの選択状態
      ObjectSetInteger(chart_id,obj_name,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
      ObjectSetInteger(chart_id,obj_name,OBJPROP_ZORDER,0);            // オブジェクトのチャートクリックイベント優先順位

      ObjectSetInteger(chart_id,obj_name,OBJPROP_LEVELCOLOR,0,clrAqua);      // ラインレベルの色設定
      
      Comment("PE 61.8  = "+(zzArray[1]-(zzArray[3]-zzArray[2])*0.618)+"\n"+
              "PE 100.0 = "+(zzArray[1]-(zzArray[3]-zzArray[2])*1.000)+"\n"+
              "PE 161.8 = "+(zzArray[1]-(zzArray[3]-zzArray[2])*1.618));
              
              
      double now_ma = iMA(NULL,0,12,0,MODE_EMA,PRICE_CLOSE,0);
              
      double entryPoint = (zzArray[1]+(zzArray[2]-zzArray[1])*0.618);
      
      double a = zzArray[2] - zzArray[3];
      double b = zzArray[2] - zzArray[1];
      
      
      
      //ポジションを持っていなかったら
      if(CurrentPosition == -1)
      {
         if(zzArray[2] > zzArray[1]&&
            zzArray[1] != old_pos&&
            entryPoint < Close[0])
           {
              Print("AAAAAAAAAAAAAAA = ",zzArray[1]);
              Print("BBBBBBBBBBBBBBB = ",zzArray[2]);
              Print("CCCCCCCCCCCCCCC = ",zzArray[3]);
              Print("DDDDDDDDDDDDDDD = ",zzArray[4]);
              OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,Bid+(80*Point),Bid-(120*Point), "Sella", 0, 0, Blue);
              old_pos = zzArray[1];
           }
      }
      else
      {
           if(OrderType()==OP_BUY)
           {
              //if(zzArray[1] > zzArray[0])
              {
              //OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
              }
           }
           if(OrderType() == OP_SELL)
           {
              if(zzArray[2] == old_pos)
              {
                 OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
              }
          }
       }
      time = Minute();
   }
   
  }
//+------------------------------------------------------------------+
