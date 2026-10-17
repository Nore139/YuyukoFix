==========================================================================
 『幽幽子大人食欲不振』非公式修正ツール  v1.0
 《幽幽子大人食欲不振》非官方修复工具  v1.0
 Unofficial fix for "Yuyuko is suffering from lack of appetite"  v1.0
==========================================================================

 日本語 ............ 1
 中文 .............. 2
 English ........... 3

==========================================================================
 1. 日本語
==========================================================================

これは『幽幽子大人食欲不振』の、有志による【非公式】の修正ツールです。
ゲームの作者（16air）とは関係ありません。
このツールはAI（Claude）を使って作成しました。

--------------------------------------------------------------------------
■ 直せる症状
--------------------------------------------------------------------------
 A. ゲームが起動しない（何も表示されない／エラーが出る）
    → 「vcredist_check.bat」を使ってください

 B. 1-3（3マップ目）に入ると画面が止まって進めない
    → 「opengl32.dll」を使ってください
    （主に Intel や AMD のグラフィック（内蔵GPUなど）で起きます）

両方の症状がある場合は、両方使ってください。

--------------------------------------------------------------------------
■ ゲームフォルダの開き方
--------------------------------------------------------------------------
 Steam のライブラリでゲームを右クリック
 →「管理」→「ローカルファイルを閲覧」
 「player.exe」が入っているフォルダが開きます。

--------------------------------------------------------------------------
■ A. 起動しない場合（vcredist_check.bat）
--------------------------------------------------------------------------
このゲームは、Microsoft Visual C++ の 2010・2012・2013・2015-2022 の
【32bit版（x86）】が必要です。64bit版の Windows でも 32bit版が必要です。

 1. 「vcredist_check.bat」をゲームフォルダにコピーする
 2. ダブルクリックする
 3. 足りないものがあれば表示されるので「Y」→ Enter
 4. 許可を求める画面が出たら「はい」
 5. 「完了しました」と出たらゲームを起動してみる

・インストーラーは Microsoft 公式サイトから直接ダウンロードします。
  Microsoft の署名を確認してから実行します。
・「Windows によって PC が保護されました」と表示された場合は、
  「詳細情報」→「実行」を押してください。
  セキュリティの警告画面が出た場合は「実行」を押してください。
・手動で入れる場合は、次のページの x86 版を使ってください:
  https://learn.microsoft.com/ja-jp/cpp/windows/latest-supported-vc-redist

--------------------------------------------------------------------------
■ B. 1-3 で止まる場合（opengl32.dll）
--------------------------------------------------------------------------
 1. 「opengl32.dll」をゲームフォルダ（player.exe と同じ場所）にコピーする
 2. ゲームを起動する

これだけです。セーブデータはそのまま使えます。

【原因】
一部のマップ用画像が縦 19200〜23040 ピクセルあり、多くの GPU が扱える
上限（16384 ピクセル）を超えているため、読み込めずに止まります。
この DLL は、大きすぎる画像だけを GPU が扱える大きさに縮めて渡します。

【注意】
・該当する背景や地形が、少しだけぼやけて見えることがあります。
・NVIDIA など上限に余裕がある GPU では、何もしません（入れても影響なし）。
・ゲームのファイルは一切書き換えません。
・起動するたびに「gl_proxy_log.txt」が作られます（動作の記録です）。
・ウイルス対策ソフトが警告することがあります。中身はソースコード
  （source フォルダ）で確認できます。

--------------------------------------------------------------------------
■ 元に戻す方法
--------------------------------------------------------------------------
ゲームフォルダから次のファイルを削除するだけです。
  opengl32.dll / gl_proxy_log.txt / vcredist_check.bat
（インストールした Visual C++ は、そのままで問題ありません）

--------------------------------------------------------------------------
■ その他
--------------------------------------------------------------------------
・無保証です。自己責任でご利用ください。
・ライセンス: MIT（LICENSE.txt）
・source フォルダに opengl32.dll のソースコードが入っています。


==========================================================================
 2. 中文
==========================================================================

这是玩家制作的《幽幽子大人食欲不振》【非官方】修复工具，
与游戏作者（16air）无关。
本工具使用 AI（Claude）制作。

--------------------------------------------------------------------------
■ 可以修复的问题
--------------------------------------------------------------------------
 A. 游戏无法启动（没有反应／出现错误）
    → 使用「vcredist_check.bat」

 B. 进入 1-3（第3张地图）时画面卡住，无法继续
    → 使用「opengl32.dll」
    （主要发生在 Intel、AMD 等显卡（核显等）上）

两个问题都有的话，请两个都使用。

--------------------------------------------------------------------------
■ 如何打开游戏文件夹
--------------------------------------------------------------------------
 在 Steam 库中右键点击游戏
 →「管理」→「浏览本地文件」
 会打开包含「player.exe」的文件夹。

--------------------------------------------------------------------------
■ A. 无法启动时（vcredist_check.bat）
--------------------------------------------------------------------------
本游戏需要 Microsoft Visual C++ 2010、2012、2013、2015-2022 的
【32位版（x86）】。即使是 64 位 Windows，也需要 32 位版。

 1. 把「vcredist_check.bat」复制到游戏文件夹
 2. 双击运行
 3. 如果显示缺少的组件，输入「Y」并按回车
 4. 弹出权限确认时，点击「是」
 5. 显示「完成」后，尝试启动游戏

・安装程序直接从微软官方网站下载，并在确认微软签名后才运行。
・如果 Windows 显示「Windows 已保护你的电脑」，
  请点击「更多信息」→「仍要运行」。
  如果出现安全警告窗口，请点击「运行」。
・手动安装时，请使用以下页面中的 x86 版本：
  https://learn.microsoft.com/zh-cn/cpp/windows/latest-supported-vc-redist

--------------------------------------------------------------------------
■ B. 在 1-3 卡住时（opengl32.dll）
--------------------------------------------------------------------------
 1. 把「opengl32.dll」复制到游戏文件夹（与 player.exe 同一位置）
 2. 启动游戏

只需要这样。存档可以继续使用。

【原因】
部分地图用的图片高度为 19200～23040 像素，超过了很多显卡能处理的
上限（16384 像素），因此无法加载而卡住。
这个 DLL 只会把过大的图片缩小到显卡能处理的尺寸。

【注意】
・相关的背景或地形可能会稍微模糊一点。
・在 NVIDIA 等上限足够的显卡上，它什么也不做（放进去也没有影响）。
・不会修改任何游戏文件。
・每次启动时会生成「gl_proxy_log.txt」（运行记录）。
・杀毒软件可能会发出警告。可以通过源代码（source 文件夹）确认内容。

--------------------------------------------------------------------------
■ 如何恢复原状
--------------------------------------------------------------------------
只需从游戏文件夹中删除以下文件：
  opengl32.dll / gl_proxy_log.txt / vcredist_check.bat
（已安装的 Visual C++ 保留即可，没有问题）

--------------------------------------------------------------------------
■ 其他
--------------------------------------------------------------------------
・不提供任何保证，请自行承担风险。
・许可证：MIT（LICENSE.txt）
・source 文件夹中包含 opengl32.dll 的源代码。


==========================================================================
 3. English
==========================================================================

This is an UNOFFICIAL fan-made fix for "Yuyuko is suffering from lack of
appetite". It is not affiliated with the game's developer (16air).
This tool was made with the help of AI (Claude).

--------------------------------------------------------------------------
* What it fixes
--------------------------------------------------------------------------
 A. The game does not start (nothing happens / an error appears)
    -> use "vcredist_check.bat"

 B. The game freezes when entering 1-3 (the 3rd map)
    -> use "opengl32.dll"
    (mostly happens on Intel / AMD graphics, e.g. integrated GPUs)

If you have both problems, use both.

--------------------------------------------------------------------------
* How to open the game folder
--------------------------------------------------------------------------
 In your Steam library, right-click the game
 -> "Manage" -> "Browse local files"
 The folder that contains "player.exe" opens.

--------------------------------------------------------------------------
* A. If the game does not start (vcredist_check.bat)
--------------------------------------------------------------------------
The game needs the 32-bit (x86) Microsoft Visual C++ 2010, 2012, 2013 and
2015-2022 runtimes. You need the 32-bit ones even on 64-bit Windows.

 1. Copy "vcredist_check.bat" into the game folder
 2. Double-click it
 3. If something is missing, type "Y" and press Enter
 4. Click "Yes" if Windows asks for permission
 5. When it says "Done", start the game

- The installers are downloaded directly from Microsoft and only run
  after their Microsoft signature is verified.
- If Windows shows "Windows protected your PC",
  click "More info" -> "Run anyway".
  If a security warning window appears, click "Run".
- To install manually, use the x86 versions on this page:
  https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist

--------------------------------------------------------------------------
* B. If the game freezes at 1-3 (opengl32.dll)
--------------------------------------------------------------------------
 1. Copy "opengl32.dll" into the game folder (next to player.exe)
 2. Start the game

That's all. Your save data keeps working.

[Cause]
Some map images are 19200-23040 pixels tall. That is more than many GPUs
can handle (16384 pixels), so the map cannot load and the game stops.
This DLL shrinks only the images that are too large, to a size the GPU
can handle.

[Notes]
- Some backgrounds or terrain may look slightly blurry.
- On GPUs with a high enough limit (e.g. NVIDIA), it does nothing
  (having it installed does no harm).
- It never modifies any game files.
- It writes "gl_proxy_log.txt" each time the game starts (a short log).
- Antivirus software may warn about it. The source code is included in
  the "source" folder.

--------------------------------------------------------------------------
* How to undo
--------------------------------------------------------------------------
Just delete these files from the game folder:
  opengl32.dll / gl_proxy_log.txt / vcredist_check.bat
(The installed Visual C++ runtimes can stay; they do no harm.)

--------------------------------------------------------------------------
* Other
--------------------------------------------------------------------------
- No warranty. Use at your own risk.
- License: MIT (LICENSE.txt)
- The "source" folder contains the source code of opengl32.dll.
