integer ch_randaddval = 2;
integer listener;
integer body_channel;
integer hud_channel;
string channel_name = "";//"[BMS] Body_HUD_Control Panel_16";

float gAlpha = 0.0;

integer foot_flag = TRUE;
integer footnail_flag = TRUE;
integer all_flag = TRUE;

key kPartsQuery;
integer iPartsLine = 0;
string notecard_parts_name = "FOOT_PARTS";
key notecard_parts_key = NULL_KEY;

list foot_parts_list = [];

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

integer do_parts_change_alpha(string parts)
{
    integer ret = FALSE;
    
    integer idx = llListFindList(foot_parts_list, [parts]);            
    
    if(idx != -1)
    {
        list info = llParseString2List(llList2String(foot_parts_list,idx+1), ["&"], [""]);
        
        integer i;
        for(i = 0 ; i < llGetListLength(info) ; i++)
        {
            list pos = llParseString2List(llList2String(info,i), [","],[""]);
        
            integer link = llList2Integer(pos,0);
            integer face = llList2Integer(pos,1);
            
            
            float alpha = llList2Float(llGetLinkPrimitiveParams(link, [?PRIM_COLOR, face?]),1);
            
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
        }
        
        info = [];
        
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
        
        integer idx = llListFindList(foot_parts_list, [parts]);
        
        if(idx != -1)
        {
            list info = llParseString2List(llList2String(foot_parts_list,idx+1), ["&"], [""]);
            
            integer i;
            for(i = 0 ; i < llGetListLength(info) ; i++)
            {
                list pos = llParseString2List(llList2String(info,i), [","],[""]);
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
            info = [];
        }
    }
}
// 各ボタン処理
integer do_btn_func(string btn, list parts_list)
{
    integer ret = FALSE;

    if(btn == "<FOOT>")
    {
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
    
    return ret;
}

config_init()
{ 
    /*--------------------*/
    /* FOOT_PARTS 読み込み */
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
                    foot_parts_list += llList2String(info,0);
                    foot_parts_list += llList2String(info,1);
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
            listener = llListen(body_channel, channel_name, "","");
        }
        
        if(id)
        {
            foot_flag = TRUE;
            footnail_flag = TRUE;
            all_flag = TRUE;
                    
            string cmd = "<EXTENTION_FOOT_ADD>";
            cmd += "{";
            // P61,62,63,64,65,66,67,68,80,81
            cmd += "P61" + "&";
            cmd += "P62" + "&";
            cmd += "P63" + "&";
            cmd += "P64" + "&";
            cmd += "P65" + "&";
            cmd += "P66" + "&";
            cmd += "P67" + "&";
            cmd += "P68" + "&";
            cmd += "P80" + "&";
            cmd += "P81";
            cmd += "}";
                
            llSay(body_channel, cmd);
            
            // 全ての面を表示する
            do_partslist_change_alpha(["P61","P62","P63","P64","P65","P66","P67","P68","P80","P81"],TRUE);
            
        }
        else
        {
            string cmd = "<EXTENTION_FOOT_REMOVE>";
            cmd += "{";
            // P61,62,63,64,65,66,67,68,80,81
            cmd += "P61" + "&";
            cmd += "P62" + "&";
            cmd += "P63" + "&";
            cmd += "P64" + "&";
            cmd += "P65" + "&";
            cmd += "P66" + "&";
            cmd += "P67" + "&";
            cmd += "P68" + "&";
            cmd += "P80" + "&";
            cmd += "P81";
            cmd += "}";
                
            llSay(body_channel, cmd);
        }
        
        
    }

    listen(integer ch, string name, key id, string message)
    {
        if(ch == body_channel && llSubStringIndex(name,"[BMS]") != -1)
        {
            
            // HUD からのメッセージなら
            if(llSubStringIndex(message,"&") == -1)
            {
                if(do_parts_change_alpha(message) == TRUE)
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
