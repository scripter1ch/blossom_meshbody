// [BMS] Mesh Body Hud Script
// Writtten by いっちゃん (ishikawasou)
//
// Version 0.9.0  ---   2017.05.21 (Beta)

// [caution]
// if you'll add list objects or many functions...
// pls check remaining free memory.

integer ch_randaddval = 1;
integer listener = 0;
integer hud_channel = 0;
integer body_channel = 0;
string channel_name = "";//"[BMS] BMSG_Body_take16";

integer rot_flag = FALSE;
integer cntr_flag = FALSE;
rotation init_rot;

key kSettingQuery;
integer iSettingLine = 0;
string notecard_setting_name = "ButtonSettings";
key notecard_setting_key = NULL_KEY;

key kPartsQuery;
integer iPartsLine = 0;
string notecard_parts_name = "HUD_BODY_PARTS";
key notecard_parts_key = NULL_KEY;


string tag_key = "";
list hud_buttons_list = [];
list hud_body_parts_list = [];

vector enable_color = <1.0, 1.0, 1.0>;
vector disable_color = <0.3, 0.3, 0.3>;

integer genCh()
{
    integer gen;

    string str_1 = llGetSubString((string)llGetOwner(),0,3);
    string str_2 = llGetSubString((string)llGetCreator(),0,3);
    gen = -1-(integer)("0x"+str_1)-(integer)("0x"+str_2) + ch_randaddval;

    return gen;
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


// ノートカード読み込み処理
config_init()
{ 
    tag_key = "";
    
    /*------------------------*/
    /* ButtonSettings 読み込み */
    key nc_key_1 = llGetInventoryKey(notecard_setting_name);
    if (nc_key_1 == notecard_setting_key)
    {
        // 設定ノートカード以外の、他のアイテムが変更されました。
        return; // この場合、ノートカードの読み込みをスキップします。
    }
    // 新しいノートカードのキーを覚えます。
    notecard_setting_key = nc_key_1;
    kSettingQuery = llGetNotecardLine(notecard_setting_name, iSettingLine);


    /*------------------*/
    /* HUD2BODY 読み込み */
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

integer check_buttons_tag(string str)
{
    integer ret = FALSE;
    
    integer s_idx = llSubStringIndex(str,"<");
    integer e_idx = llSubStringIndex(str,">");
    if(s_idx != -1 && e_idx != -1)
    {
        ret = TRUE;
    }
    
    return ret;
}

string check_hudbody(integer link, integer face)
{
    string ret_str = "";

    integer idx = llListFindList(hud_body_parts_list, [(string)link + "," + (string)face]);
    if(idx != -1)
    {
        ret_str = llList2String(hud_body_parts_list, idx-1);
    }
    
    return ret_str;
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

string getButtonTag(integer link, integer face)
{
    string tag_str = "";
    
    integer i = 0;
    
    for(i = 0 ; i < llGetListLength(hud_buttons_list); i++)
    {
        list info = llParseString2List(llList2String(hud_buttons_list,i), ["-"], [""]);
    
        if(llList2String(info,0) == ((string)link + "," + (string)face))
        {
            tag_str = llList2String(info,1);
            info = [];
            jump loop_out;
        }
        info = [];
    }
    
    @loop_out;
    
    return tag_str;
}

hud_body_enable_fromlist(list parts_list, integer flag)
{
    integer i = 0;
    for(i = 0 ; i < llGetListLength(parts_list) ; i++)
    {
        string parts = llList2String(parts_list, i);
        integer idx = llListFindList(hud_body_parts_list, [parts]);
        
        if(idx != -1)
        {    
            list pos = llParseString2List(llList2String(hud_body_parts_list,idx+1), [","],[""]);
            integer link = llList2Integer(pos,0);
            integer face = llList2Integer(pos,1);
            
            if(link != -1)
            {
                if(flag == TRUE)
                {
                    llSetLinkColor(link, enable_color, face);
                }
                else
                {
                    llSetLinkColor(link, disable_color, face);
                }
            }
            pos = [];
        }
    }    
}

hud_body_enable(string str)
{
    list info = llParseString2List(str, ["$"], [""]);

    integer idx = llListFindList(hud_body_parts_list, [llList2String(info,0)]);
    if(idx != -1)
    {
        list pos_list = llParseString2List(llList2String(hud_body_parts_list, idx+1),[","],[""]);
        
        integer link = llList2Integer(pos_list,0);
        integer face = llList2Integer(pos_list,1);
        
        float alpha = llList2Float(info,1);
        
        if(alpha == 1.0)
        {
            llSetLinkColor(link, enable_color, face);
        }
        else
        {
            llSetLinkColor(link, disable_color, face);
        }
        
        pos_list = [];
    }
    info = [];
}

default
{
    state_entry()
    {
        hud_channel = genCh();
        listener = llListen(hud_channel, channel_name, "","");
        body_channel = hud_channel + 1;
        
        restart_start_message();
        
        // 起動時にノートカードを一通り読み込みます。
        config_init();
        
        init_rot = llGetLocalRot();
        
        
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
        if(query_id == kSettingQuery)
        {
            // ノートカードの 1 行です。
            if (data == EOF) 
            {
                llOwnerSay("Finished reading [" + notecard_setting_name + "] configuration.");
            } 
            else
            {
                data = strReplace(data, " ", "");
                data = strReplace(data, "\n", "");
                
                if(data != "")
                {
                    if(check_buttons_tag(data) == TRUE)
                    {
                        tag_key = data;
                    }
                    else if(tag_key != "")
                    {
                        hud_buttons_list += data + "-" + tag_key;
                    }
                    waiting_message();
                }
                
                // カウンタをインクリメントします。
                ++iSettingLine;
                //ノートカードの次の行をリクエストします。
                kSettingQuery = llGetNotecardLine(notecard_setting_name, iSettingLine);
            }
        }
        else if(query_id == kPartsQuery)
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
                    list info = llParseString2List(data, ["="], [""]);
                    
                    hud_body_parts_list += llList2String(info, 0);
                    hud_body_parts_list += llList2String(info, 1);
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
            hud_channel = genCh();
            body_channel = hud_channel + 1;
            listener = llListen(hud_channel, channel_name, "","");
        }
    }

    touch_start(integer s)
    {
        integer link = llDetectedLinkNumber(0);
        integer face = llDetectedTouchFace(0);
        
        string btn_tag = getButtonTag(link, face);
        
        // for Debug Message
        
        // <CONTROL3DMODEL>
        if(btn_tag == "<CONTROL3DMODEL>")
        {
            if(rot_flag == FALSE)
            {
                llSetLocalRot(init_rot * llEuler2Rot(<0,PI_BY_TWO*2,0>)); 
                rot_flag = TRUE;
            }
            else
            {
                llSetLocalRot(init_rot); 
                rot_flag = FALSE;
            }
        }
        else if(btn_tag == "<CONTROLER>")
        {
            if(cntr_flag == FALSE)
            {
                llSetLocalRot(init_rot * llEuler2Rot(<PI_BY_TWO*2,0,PI_BY_TWO>)); 
                cntr_flag = TRUE;
            }
            else
            {
                llSetLocalRot(init_rot); 
                cntr_flag = FALSE;
            }
        }
        else if(btn_tag == "<CHEST>")
        {
            // P6,7,8,23,24,25,26,27,28,29,30,31,32,33,34,35 
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P6" + "&";
            cmd += "P7" + "&";
            cmd += "P8" + "&";
            cmd += "P23" + "&";
            cmd += "P24" + "&";
            cmd += "P25" + "&";
            cmd += "P26" + "&";
            cmd += "P27" + "&";
            cmd += "P28" + "&";
            cmd += "P29" + "&";
            cmd += "P30" + "&";
            cmd += "P31" + "&";
            cmd += "P32" + "&";
            cmd += "P33" + "&";
            cmd += "P34" + "&";
            cmd += "P35";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<BREAST>")
        {
            // P24.25.26.27.28.29.30.31.33.34
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P24" + "&";
            cmd += "P25" + "&";
            cmd += "P26" + "&";
            cmd += "P27" + "&";
            cmd += "P28" + "&";
            cmd += "P29" + "&";
            cmd += "P30" + "&";
            cmd += "P31" + "&";
            cmd += "P33" + "&";
            cmd += "P34";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<NIPPLE>")
        {
            // P30,31
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P30" + "&";
            cmd += "P31";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<WAIST>")
        {
            // P36,37,38,75,76,77
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P36" + "&";
            cmd += "P37" + "&";
            cmd += "P38" + "&";
            cmd += "P75" + "&";
            cmd += "P76" + "&";
            cmd += "P77";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<ARM>")
        {
            // P11,12,13,14,15,16,17,18,19,20
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P11" + "&";
            cmd += "P12" + "&";
            cmd += "P13" + "&";
            cmd += "P14" + "&";
            cmd += "P15" + "&";
            cmd += "P16" + "&";
            cmd += "P17" + "&";
            cmd += "P18" + "&";
            cmd += "P19" + "&";
            cmd += "P20";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<UPPERLEG>")
        {
            // P39,40,41,42,43,44,45,46,47,48
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P39" + "&";
            cmd += "P40" + "&";
            cmd += "P41" + "&";
            cmd += "P42" + "&";
            cmd += "P43" + "&";
            cmd += "P44" + "&";
            cmd += "P45" + "&";
            cmd += "P46" + "&";
            cmd += "P47" + "&";
            cmd += "P48";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<BOTTOMLEG>")
        {
            // P49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64
                        string cmd = btn_tag;
            cmd += "{";
            cmd += "P49" + "&";
            cmd += "P50" + "&";
            cmd += "P51" + "&";
            cmd += "P52" + "&";
            cmd += "P53" + "&";
            cmd += "P54" + "&";
            cmd += "P55" + "&";
            cmd += "P56" + "&";
            cmd += "P57" + "&";
            cmd += "P58" + "&";
            cmd += "P59" + "&";
            cmd += "P60" + "&";
            cmd += "P61" + "&";
            cmd += "P62" + "&";
            cmd += "P63" + "&";
            cmd += "P64";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<BACK>")
        {
            // P71,72,73,74,75,76
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P71" + "&";
            cmd += "P72" + "&";
            cmd += "P73" + "&";
            cmd += "P74" + "&";
            cmd += "P75" + "&";
            cmd += "P76";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<HIP>")
        {
            // P38,77
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P38" + "&";
            cmd += "P77";            
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<HAND>")
        {
            // P21,22,78,79
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P21" + "&";
            cmd += "P22" + "&";
            cmd += "P78" + "&";
            cmd += "P79";            
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<FOOT>")
        {
            // P61,62,63,64,65,66,67,68,80,81
            string cmd = btn_tag;
            cmd += "{";
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
        else if(btn_tag == "<HANDNAIL>")
        {
            // P78,79
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P78" + "&";
            cmd += "P79";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<FOOTNAIL>")
        {
            // P80,81
            string cmd = btn_tag;
            cmd += "{";
            cmd += "P80" + "&";
            cmd += "P81";
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        else if(btn_tag == "<ALL>")
        {
            // P1 ～ ALL(81)
            string cmd = btn_tag;
            cmd += "{";
            integer i;
            for(i = 0 ; i < llGetListLength(hud_body_parts_list); i+=2)
            {
                cmd += llList2String(hud_body_parts_list,i);
                if(i < llGetListLength(hud_body_parts_list)-2)
                {
                    cmd += "&";
                }
            }
            cmd += "}";
            
            llSay(body_channel, cmd);
        }
        
        // HUD Mesh Body Touch
        else
        {
            string parts_str = check_hudbody(link, face);
            if(parts_str != "")
            {
                llSay(body_channel, parts_str);
            }
        }
        
        //llOwnerSay((string)((float)llGetFreeMemory()/1000.0) + " KB free");
    }
    
    listen(integer ch, string name, key id, string message)
    {
        if(ch == hud_channel && llSubStringIndex(name,"[BMS]") != -1)
        {
            // Mesh Body からのメッセージなら
            if(llSubStringIndex(message,":") != -1)
            {
                list info_list = llParseString2List(message, ["{",":"], [""]);
                list parts_list = llParseString2List(strReplace(llList2String(info_list,1),"}",""),["&"],[""]);
                integer flag = llList2Integer(info_list,2);
    
                hud_body_enable_fromlist(parts_list, flag);
                
                info_list = [];
                parts_list = [];                
            }
            else if(llSubStringIndex(message,"$") != -1)
            {
                hud_body_enable(message);
            }
        }
    }
}