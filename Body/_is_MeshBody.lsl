// [BMS] Mesh Body Script
// Writtten by いっちゃん (ishikawasou)
//
// Version 0.9.0  ---   2017.05.21 (Beta)

integer ch_randaddval = 2; // BODY
integer listener;
integer body_channel;
integer hud_channel;
integer head_channel;
string channel_name = "";//"[BMS] Body_HUD_Control Panel_16";

float gAlpha = 0.0;

integer chest_flag = TRUE;
integer breast_flag = TRUE;
integer nipple_flag = TRUE;
integer waist_flag = TRUE;
integer arm_flag = TRUE;
integer upperleg_flag = TRUE;
integer bottomleg_flag = TRUE;
integer back_flag = TRUE;
integer hip_flag = TRUE;
integer hand_flag = TRUE;
integer handnail_flag = TRUE;
integer foot_flag = TRUE;
integer footnail_flag = TRUE;
integer all_flag = TRUE;

integer extention_foot_flag = FALSE;
integer bms_head_flag = FALSE;

key kPartsQuery;
integer iPartsLine = 0;
string notecard_parts_name = "BODY_PARTS";
key notecard_parts_key = NULL_KEY;

list body_parts_list = [];

integer genCh()
{
    integer gen;

    string str_1 = llGetSubString((string)llGetOwner(),0,3);
    string str_2 = llGetSubString((string)llGetCreator(),0,3);
    gen = -1-(integer)("0x"+str_1)-(integer)("0x"+str_2) + ch_randaddval;

    return gen;
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

integer extention_foot_check(string parts)
{
    integer ret = FALSE;

    if(extention_foot_flag == TRUE)
    {
        // P61,62,63,64,65,66,67,68,80,81
        if(parts == "P61" || parts == "P62" || parts == "P63" || parts == "P64" ||
            parts == "P65" || parts == "P66" || parts == "P67" || parts == "P68" ||
            parts == "P80" || parts == "P81")
        {
            ret = TRUE;
        }
    }
    
    return ret;
}

integer do_parts_change_alpha(string parts, integer force_alpha_flag)
{
    integer ret = FALSE;
    
    if(extention_foot_check(parts) == TRUE)
    {
        ret = FALSE;
        
        if(force_alpha_flag != TRUE)
        {
            return ret;
        }
    }

    integer idx = llListFindList(body_parts_list, [parts]);            
    
    if(idx != -1)
    {
        list pos = llParseString2List(llList2String(body_parts_list,idx+1), [","],[""]);
        integer link = llList2Integer(pos,0);
        integer face = llList2Integer(pos,1);
        
        
        float alpha;
        
        if(force_alpha_flag == TRUE)
        {
            alpha = 1.0;
        }
        else
        {
            alpha = llList2Float(llGetLinkPrimitiveParams(link, [ PRIM_COLOR, face ]),1);
        }
        
        if(alpha == 1.0)
        {
            llSetLinkAlpha(link, 0.0, face);
            gAlpha = 0.0;
        }
        else
        {
            llSetLinkAlpha(link, 1.0, face);
            gAlpha = 1.0;
        }
        
        pos = [];
        
        ret = TRUE;
    }
    
    return ret;
}

do_partslist_change_alpha(list parts_list, integer flag)
{
    integer i = 0;
    for(i = 0 ; i < llGetListLength(parts_list) ; i++)
    {
        string parts = llList2String(parts_list, i);
        
        if(extention_foot_check(parts) == TRUE)
        {
            jump end;
        }
        
        integer idx = llListFindList(body_parts_list, [parts]);
        if(idx != -1)
        {
            list pos = llParseString2List(llList2String(body_parts_list, idx+1), [","],[""]);
            integer link = llList2Integer(pos,0);
            integer face = llList2Integer(pos,1);
            
            if(flag == TRUE)
            {
                llSetLinkAlpha(link, 1.0, face);
            }
            else
            {
                llSetLinkAlpha(link, 0.0, face);
            }
            
            pos = [];
        }
        
        @end;
    }
}

// 各ボタン処理
integer do_btn_func(string btn, list parts_list)
{
    integer ret = FALSE;

    if(btn == "<CHEST>")
    {
        if(chest_flag == TRUE)
        {
            ret = chest_flag = FALSE;
            do_partslist_change_alpha(parts_list, chest_flag);
        }
        else
        {
            ret = chest_flag = TRUE;
            do_partslist_change_alpha(parts_list, chest_flag);
        }
    }
    else if(btn == "<BREAST>")
    {
        if(breast_flag == TRUE)
        {
            ret = breast_flag = FALSE;
            do_partslist_change_alpha(parts_list, breast_flag);
        }
        else
        {
            ret = breast_flag = TRUE;
            do_partslist_change_alpha(parts_list, breast_flag);
        }
    }
    else if(btn == "<NIPPLE>")
    {
        if(nipple_flag == TRUE)
        {
            ret = nipple_flag = FALSE;
            do_partslist_change_alpha(parts_list, nipple_flag);

        }
        else
        {
            ret = nipple_flag = TRUE;
            do_partslist_change_alpha(parts_list, nipple_flag);
        }
    }
    else if(btn == "<WAIST>")
    {
        if(waist_flag == TRUE)
        {
            ret = waist_flag = FALSE;
            do_partslist_change_alpha(parts_list, waist_flag);
        }
        else
        {
            ret = waist_flag = TRUE;
            do_partslist_change_alpha(parts_list, waist_flag);
        }
    }
    else if(btn == "<ARM>")
    {
        if(arm_flag == TRUE)
        {
            ret = arm_flag = FALSE;
            do_partslist_change_alpha(parts_list, arm_flag);
        }
        else
        {
            ret = arm_flag = TRUE;
            do_partslist_change_alpha(parts_list, arm_flag);
        }
    }    
    else if(btn == "<UPPERLEG>")
    {
        if(upperleg_flag == TRUE)
        {
            ret = upperleg_flag = FALSE;
            do_partslist_change_alpha(parts_list, upperleg_flag);
        }
        else
        {
            ret = upperleg_flag = TRUE;
            do_partslist_change_alpha(parts_list, upperleg_flag);
        }
    }
    else if(btn == "<BOTTOMLEG>")
    {
        if(bottomleg_flag == TRUE)
        {
            ret = bottomleg_flag = FALSE;
            do_partslist_change_alpha(parts_list, bottomleg_flag);
        }
        else
        {
            ret = bottomleg_flag = TRUE;
            do_partslist_change_alpha(parts_list, bottomleg_flag);
        }
    }
    else if(btn == "<BACK>")
    {
        if(back_flag == TRUE)
        {
            ret = back_flag = FALSE;
            do_partslist_change_alpha(parts_list, back_flag);
        }
        else
        {
            ret = back_flag = TRUE;
            do_partslist_change_alpha(parts_list, back_flag);
        }
    }
    else if(btn == "<HIP>")
    {
        if(hip_flag == TRUE)
        {
            ret = hip_flag = FALSE;
            do_partslist_change_alpha(parts_list, hip_flag);
        }
        else
        {
            ret = hip_flag = TRUE;
            do_partslist_change_alpha(parts_list, hip_flag);
        }
    }    
    else if(btn == "<HAND>")
    {
        if(hand_flag == TRUE)
        {
            ret = hand_flag = FALSE;
            do_partslist_change_alpha(parts_list, hand_flag);
        }
        else
        {
            ret = hand_flag = TRUE;
            do_partslist_change_alpha(parts_list, hand_flag);
        }
    }
    else if(btn == "<HANDNAIL>")
    {
        if(handnail_flag == TRUE)
        {
            ret = handnail_flag = FALSE;
            do_partslist_change_alpha(parts_list, handnail_flag);
        }
        else
        {
            ret = handnail_flag = TRUE;
            do_partslist_change_alpha(parts_list, handnail_flag);
        }
    }
    else if(btn == "<FOOT>")
    {
        if(extention_foot_flag == TRUE)
        {
            return foot_flag;
        }
        
        if(foot_flag == TRUE)
        {
            ret = foot_flag = FALSE;
            do_partslist_change_alpha(parts_list, foot_flag);
        }
        else
        {
            ret = foot_flag = TRUE;
            do_partslist_change_alpha(parts_list, foot_flag);
        }
    }    
    else if(btn == "<FOOTNAIL>")
    {
        if(extention_foot_flag == TRUE)
        {
            return footnail_flag;
        }

        if(footnail_flag == TRUE)
        {
            ret = footnail_flag = FALSE;
            do_partslist_change_alpha(parts_list, footnail_flag);
        }
        else
        {
            ret = footnail_flag = TRUE;
            do_partslist_change_alpha(parts_list, footnail_flag);
        }
    }
    else if(btn == "<ALL>")
    {
        if(all_flag == TRUE)
        {
            ret = all_flag = FALSE;
            do_partslist_change_alpha(parts_list, all_flag);
        }
        else
        {
            ret = all_flag = TRUE;
            do_partslist_change_alpha(parts_list, all_flag);
        }
    }
    else if(btn == "<CUSTOM>")
    {
        do_partslist_change_alpha(parts_list, FALSE);
    }
    else if(btn == "<EXTENTION_FOOT_ADD>")
    {        
        do_partslist_change_alpha(parts_list, FALSE);
        ret = foot_flag = extention_foot_flag = TRUE;
    }
    else if(btn == "<EXTENTION_FOOT_REMOVE>")
    {
        extention_foot_flag = FALSE;
        do_partslist_change_alpha(parts_list, TRUE);
        ret = foot_flag = TRUE;
    }
    
    return ret;
}

set_bms_head()
{
    if(bms_head_flag == TRUE)
    {
        do_parts_change_alpha("P1", TRUE);
    }
    else
    {
        do_parts_change_alpha("P1", FALSE);
    }
}

restart_start_message()
{
    llOwnerSay((string)((float)llGetFreeMemory()/1000.0) + " KB free");
    llOwnerSay("\n---- ALL Reset Start ----\n Please, wait some mins.");
}
restart_end_message()
{
    llOwnerSay("\n---- Reset Complete ----\n Thank you for waiting :)");
    llOwnerSay((string)((float)llGetFreeMemory()/1000.0) + " KB free");
}
waiting_message()
{
    llOwnerSay(".......");
}

config_init()
{ 
    /*--------------------*/
    /* BODY_PARTS 読み込み */
    key nc_key_2 = llGetInventoryKey(notecard_parts_name);
    if (nc_key_2 == notecard_parts_key)
    {
        // 設定ノートカード以外の、他のアイテムが変更されました。
        return; // この場合、ノートカードの読み込みをスキップします。
    }
    // 新しいノートカードのキーを覚えます。
    notecard_parts_key = nc_key_2;
    kPartsQuery = llGetNotecardLine(notecard_parts_name, iPartsLine);
}

default
{
    state_entry()
    {
        body_channel = genCh();
        hud_channel = body_channel - 1;
        head_channel = body_channel + 1;
        listener = llListen(body_channel,channel_name,"","");
        
        restart_start_message();
        
        // 起動時にノートカードを一通り読み込みます。
        config_init();
    }
    
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            // インベントリが変更になったらノートカードを読み込みます。
            llResetScript();
            //config_init();
        }
    }
    
    dataserver(key query_id, string data)
    {
        if(query_id == kPartsQuery)
        {
            // ノートカードの 1 行です。
            if (data == EOF) 
            {
                llOwnerSay("Finished reading [" + notecard_parts_name + "] configuration.");
                restart_end_message();
            } 
            else
            {
                data = strReplace(data, " ", "");
                data = strReplace(data, "\n", "");
                if(llSubStringIndex(data,"#") != -1)
                {
                    // # なら読み飛ばし
                    jump read_out;
                }
                
                if(data != "")
                {
                    list info = llParseString2List(data, ["="],[""]);
                    body_parts_list += llList2String(info,0);
                    body_parts_list += llList2String(info,1);
                    info = [];
                    waiting_message();
                }
                
                @read_out;
                
                // カウンタをインクリメントします。
                ++iPartsLine;
                //ノートカードの次の行をリクエストします。
                kPartsQuery = llGetNotecardLine(notecard_parts_name, iPartsLine);
            }
        }
    }
    attach(key id)
    {
        if(listener != 0)
        {
            llListenRemove(listener);
            body_channel = genCh();
            hud_channel = body_channel - 1;
            head_channel = body_channel + 1;
            listener = llListen(body_channel, channel_name, "","");
            
            extention_foot_flag = FALSE;
            
            // [BMS] Head が装着されているか確認
            llSay(head_channel, "<BMS_HEAD_CHECK>");
        }
    }

    listen(integer ch, string name, key id, string message)
    {
        if(ch == body_channel && llSubStringIndex(name,"[BMS]") != -1)
        {
            if(message == "<BMS_HEAD_ADD>" || message == "<BMS_HEAD_REMOVE>")
            {
                // [BMS] Head 対応処理を行う
                if(message == "<BMS_HEAD_ADD>")
                {
                    bms_head_flag = TRUE;
                }
                else
                {
                    bms_head_flag = FALSE;
                }
                set_bms_head();
            }
            // HUD からのメッセージなら
            else if(llSubStringIndex(message,"&") == -1)
            {
                if(do_parts_change_alpha(message, FALSE) == TRUE)
                {
                    // Message を HUD に返す
                    llSay(hud_channel, message + "$" + (string)gAlpha);
                }
                    
            }
            // ツールボタンコマンド
            else
            {
                //llOwnerSay(message);
                list info_list = llParseString2List(message, ["{"], [""]);
                
                string btn_name = llList2String(info_list,0);

                list parts_list = llParseString2List(strReplace(llList2String(info_list,1),"}",""),["&"],[""]);
                
                integer ret = do_btn_func(btn_name, parts_list);
                
                parts_list = [];
                info_list = [];
                
                // Message を HUD に返す
                llSay(hud_channel, message + ":" + (string)ret);
            }
        }
    }
}
