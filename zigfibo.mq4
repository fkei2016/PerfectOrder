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
  double pe[3]={0.0f,0.0f,0.0f};
  bool ispe[3]={0,0,0};
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
   
   
   //ポジションを持っていなかったら15分に１回処理をする
   if(CurrentPosition == -1)
   {
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
              
         pe[0] = (zzArray[1]-(zzArray[3]-zzArray[2])*0.818);
         pe[1] = (zzArray[1]-(zzArray[3]-zzArray[2])*1.000);
         pe[2] = (zzArray[1]-(zzArray[3]-zzArray[2])*1.618);
      
         if(zzArray[3] > zzArray[2]&&
           zzArray[2] < zzArray[1]&&
           zzArray[3] > zzArray[1]&&
           zzArray[1] != old_pos)
           {
              OrderSend(Symbol() ,OP_SELL, 1, Bid, 3,zzArray[1], 0, "Sella", 0, 0, Blue);
              old_pos = zzArray[1];
           }
      
         time = Minute();
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
        if(OrderType()==OP_SELL)
        {
           for(int i =0; i < 3 ;i++)
           {
              if(ispe[i] == false)
              {
                 if(pe[i] > Close[0])
                 {
                    ispe[i] = true;
                 }
              }
              else
              {
                 if(pe[i] < Close[0])
                 {
                    OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
                    Print(pe[0]," = ",pe[1]," = ",pe[2]," = ",i);
                    ispe[0] = false;
                    ispe[1] = false;
                    ispe[2] = false;
                 }
              }
           }
        }
      }
  }
//+------------------------------------------------------------------+
