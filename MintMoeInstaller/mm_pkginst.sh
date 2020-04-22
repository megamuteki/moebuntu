#!/bin/bash


#ターミナルの設定
if [ $(dpkg-query -W -f='${Status}' xfce4-terminal  2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	termapp="xfce4-terminal"

else
	termapp="xterm"
fi


#エディタの設定
if [ $(dpkg-query -W -f='${Status}' leafpad  2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	editapp="leafpad"

else
	echo "leafpad  エディタをインストールしてください。"
fi

#エディタの設定
if [ $(dpkg-query -W -f='${Status}' thunar  2>/dev/null | grep -c "ok installed") -eq 1 ];
then
	filemanapp="thunar"

else
	echo "thunar ファイルマネージャーをインストールしてください。"
fi





######################################################
#   変数の準備
#######################################################

#Pkgリストに変換するテキストファイルの場所とファイル名
datadir=$(cd $(dirname "$0") && pwd)/mm_pkginst_files
catalog=$(cat ${datadir}/00pkgcatalog.txt)

#解説文
infotxt=${datadir}/00infotxt.txt


# 共通関数の読み込み
. ${datadir}/00common.fnc

# テキストファイルの行数（ループの脱出判定に使用）
linecount=$(echo "$catalog" | wc -l)

# 表示に使用するリスト
display=""

# 変更箇所の検出に使用するリスト
before=""

# 改行
BR="
"


#######################################################
#  テキストファイルをリスト形式に変換
#######################################################


_txt2list()
{
	echo 0
	
	rm -f "/tmp/_pkginstall_display"
	rm -f "/tmp/_pkginstall_before"
	rm -f "/tmp/_pkginstall_neterr"


	#ネットワークの通信状況の確認	
	wget -qq --spider -t 1 -T 10 google.com
	if [ $? -gt 0 ] ; then
		touch "/tmp/_pkginstall_neterr"
		return 1
	fi
	
	# 区切り文字を改行に
	_IFS="$IFS";IFS="$BR"
	
	# パッケージカタログからリストを作成
	i=0
	while [ $linecount -gt $i ] ; do
		
		# 必要な情報を取り出す
		name=$(echo "$catalog" | sed -n "$(expr $i + 1)p")
		pow=$( echo "$catalog" | sed -n "$(expr $i + 2)p")
		method=$( echo "$catalog" | sed -n "$(expr $i + 3)p")
		desc=$(echo "$catalog" | sed -n "$(expr $i + 4)p")
		id=$(  echo "$catalog" | sed -n "$(expr $i + 5)p")
		
		# 表示用と比較用の二つのリストを生成する
		display="${display}$(${datadir}/${id} -c)${BR}${name}${BR}${pow}${BR}${method}${BR}${desc}${BR}${id}${BR}"
		before="${before}$(${datadir}/${id} -c)|${name}|${pow}|${method}|${desc}|${id}|${BR}"
		i=$(expr $i + 6)
		
	done
	
	# 区切り文字を戻す
	IFS="$_IFS"
	
	echo "${display}" > "/tmp/_pkginstall_display"
	echo "${before}"  > "/tmp/_pkginstall_before"
	
	return 0
}



_txt2list | \
yad --progress --title="起動中" --on-top --center --window-icon=checkbox --image=checkbox \
--text "インストール状態を確認しています..." --pulsate --auto-close


# ネットワーク接続が確認できない場合は、設定パネルを出して終了する
if [ -f "/tmp/_pkginstall_neterr" ] ; then
	rm -f "/tmp/_pkginstall_neterr"
	nohup yad --title="エラー" --on-top --center --window-icon=checkbox --image=checkbox \
	--text "インターネットに接続できていません" >/dev/null 2>&1 &
	nohup nm-connection-editor >/dev/null 2>&1 &
	nohup mm_proxy >/dev/null 2>&1 &
	exit 1
fi


display=$(cat "/tmp/_pkginstall_display")
before=$(cat  "/tmp/_pkginstall_before")

# 一時ファイルを削除
rm -f "/tmp/_pkginstall_display"
rm -f "/tmp/_pkginstall_before"



#######################################################
#  リストから変更したい項目を選択
#######################################################
# リストを表示
ipcrm --all=shm
fkey=$(($RANDOM * $$))

after=$(
	echo "$display" | yad \
	--plug="$fkey" --tabnum=1 \
	--list --checklist --hide-column="6" \
	--text="導入したい機能にチェックを入れてください（チェックを外したものは削除されます）。" \
	--column="導入" --column="パッケージ名" --column="負荷" --column="方法" --column="説明" --column="ID" &

	yad --plug="$fkey" --tabnum=2 \
	--text-info \
    --filename=$infotxt --fontname=Monospace 2>/dev/null &
		
	yad --key="$fkey" \
	--width="640" --height="480" --on-top --center \
	--title="追加パッケージ設定ウィザード" --window-icon=checkbox \
	--notebook --tab="パッケージ" --tab="情報"

)

# キャンセルした場合は終了
if [ $? -gt 0 ] ; then
	exit 1
fi

#######################################################
#  変更箇所の検出・パース
#######################################################


# リストを比較するための一時ファイルを作成
echo "${before}" > "/tmp/_pkginstall_before"
echo "${after}"  > "/tmp/_pkginstall_after"

# 操作前のリストと操作後のリストを比較し、それぞれの変更箇所を取り出す
diff=$(diff "/tmp/_pkginstall_before" "/tmp/_pkginstall_after" | grep ^.\ TRUE\|)

# 一時ファイルを削除
rm -f "/tmp/_pkginstall_before"
rm -f "/tmp/_pkginstall_after"

if [ "${diff}" == "" ] ; then
	exit 1
fi
in=$( echo "$diff" | grep ^\> | sed -e 's/^> //')
out=$(echo "$diff" | grep ^\< | sed -e 's/^< //')


# 確認用のリストを作成・表示
if [ ! "${in}" == "" ] ; then
	in_disp=${BR}" 【インストール】"${BR}$(echo "$in" | awk -F"|" '{print "  "$2}')${BR}
else
	in_disp=""
fi
if [ ! "${out}" == "" ] ; then
	out_disp=${BR}" 【アンインストール】"${BR}$(echo "$out" | awk -F"|" '{print "  "$2}')${BR}
else
	out_disp=""
fi

yad --title="追加パッケージ設定ウィザード" --on-top --center --window-icon=checkbox --image=checkbox \
--text "${BR} 以下の変更を適用しますか？${BR}${in_disp}${out_disp} "

# キャンセルした場合は終了
if [ $? -gt 0 ] ; then
	exit 1
fi

# 処理用のリストを作成
in_list=$( echo "$in"  | awk -F"|" '{print $6}')
out_list=$(echo "$out" | awk -F"|" '{print $6}')


#######################################################
#  インストールと後処理
#######################################################

# 残りの処理は別窓に渡す
x-terminal-emulator -e "${datadir}/00doinst" "$(echo ${in_list} \| ${out_list})"

# 終了待ち
while true ; do
	if [ $(ps alxxx | grep mm_pkginst_files/00doinst | grep -v grep | \
	       grep -v thunar | grep -v leafpad | wc -l) -eq 0 ] ; then
		break
	fi
	sleep 1
done

# ログを開く
nohup leafpad $(_logfile) &

# 区切り文字を改行に
_IFS="$IFS";IFS="$BR"

touch "$(_postfile)"
# ファイルに記録されたコマンドを立ち上げる
for line in $(cat "$(_postfile)") ; do
	if [ "a${line}" != "a" ] ; then
		eval nohup ${line} &
	fi
done

# 区切り文字を戻す
IFS="$_IFS"

# 記録ファイルを削除する
rm -f "$(_postfile)"
rm -f nohup.out


