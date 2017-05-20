integer ch_randaddval = 1;
integer listener = 0;
integer body_channel = 0;
string channel_name = "[BMS] BMSG_Body_take16";

integer genCh()
{
    integer gen;

    string str_1 = llGetSubString((string)llGetOwner(),0,3);
    string str_2 = llGetSubString((string)llGetCreator(),0,3);
    gen = -1-(integer)("0x"+str_1)-(integer)("0x"+str_2) + ch_randaddval;

    return gen;
}

default
{
    state_entry()
    {
        integer hud_channel = genCh();
        body_channel = hud_channel + 1;
    }

    attach(key id)
    {
        if(id)
        {
            integer hud_channel = genCh();
            body_channel = hud_channel + 1;

            string cmd = "<CUSTOM>";
            cmd += "{";
            // P11,12,13,14,15,16,17,18,19,20
            cmd += "P11" + "&";
            cmd += "P12" + "&";
            cmd += "P13" + "&";
            cmd += "P14" + "&";
            cmd += "P15" + "&";
            cmd += "P16" + "&";
            cmd += "P17" + "&";
            cmd += "P18" + "&";
            cmd += "P19" + "&";
            cmd += "P20" + "&";

            // P26,27,28,29,30,31,32,33,34,35,36,37,38,
            cmd += "P26" + "&";
            cmd += "P27" + "&";
            cmd += "P28" + "&";
            cmd += "P29" + "&";
            cmd += "P30" + "&";
            cmd += "P31" + "&";
            cmd += "P32" + "&";
            cmd += "P33" + "&";
            cmd += "P34" + "&";
            cmd += "P35" + "&";
            cmd += "P36" + "&";
            cmd += "P37" + "&";
            cmd += "P38" + "&";

            // P71,72,73,74,75,76,77
            cmd += "P71" + "&";
            cmd += "P72" + "&";
            cmd += "P73" + "&";
            cmd += "P74" + "&";
            cmd += "P75" + "&";
            cmd += "P76" + "&";
            cmd += "P77";
            cmd += "}";

            llSay(body_channel, cmd);
        }
    }
}
