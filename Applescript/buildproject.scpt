FasdUAS 1.101.10   ��   ��    k             l     ��  ��      buildproject.applescript     � 	 	 2   b u i l d p r o j e c t . a p p l e s c r i p t   
  
 l     ��  ��      QOLocalizableStrings     �   *   Q O L o c a l i z a b l e S t r i n g s      l     ��������  ��  ��        l     ��  ��    #  Created by user on 21.05.11.     �   :   C r e a t e d   b y   u s e r   o n   2 1 . 0 5 . 1 1 .      l     ��  ��    = 7 Copyright 2011 __MyCompanyName__. All rights reserved.     �   n   C o p y r i g h t   2 0 1 1   _ _ M y C o m p a n y N a m e _ _ .   A l l   r i g h t s   r e s e r v e d .      l     ��������  ��  ��        l     ��   ��    0 * Exapmple of call objective-c from script:      � ! ! T   E x a p m p l e   o f   c a l l   o b j e c t i v e - c   f r o m   s c r i p t :   " # " l     �� $ %��   $ &   #import "CreatePackageAction.h"    % � & & @   # i m p o r t   " C r e a t e P a c k a g e A c t i o n . h " #  ' ( ' l     �� ) *��   ) + %  @implementation CreatePackageAction    * � + + J     @ i m p l e m e n t a t i o n   C r e a t e P a c k a g e A c t i o n (  , - , l     �� . /��   . T N  + (BOOL)writeDictionary:(NSDictionary *)dictionary withName:(NSString *)name    / � 0 0 �     +   ( B O O L ) w r i t e D i c t i o n a r y : ( N S D i c t i o n a r y   * ) d i c t i o n a r y   w i t h N a m e : ( N S S t r i n g   * ) n a m e -  1 2 1 l     �� 3 4��   3   {    4 � 5 5    { 2  6 7 6 l     �� 8 9��   8 ? 9     return [dictionary writeToFile:name atomically:YES];    9 � : : r           r e t u r n   [ d i c t i o n a r y   w r i t e T o F i l e : n a m e   a t o m i c a l l y : Y E S ] ; 7  ; < ; l     �� = >��   =   }    > � ? ?    } <  @ A @ l     �� B C��   B   @end    C � D D 
   @ e n d A  E F E l     ��������  ��  ��   F  G H G l     �� I J��   I � } In a script you can then use a call method "m" of class "c" with parameters{ y,z} statement to call this method (Listing 3).    J � K K �   I n   a   s c r i p t   y o u   c a n   t h e n   u s e   a   c a l l   m e t h o d   " m "   o f   c l a s s   " c "   w i t h   p a r a m e t e r s {   y , z }   s t a t e m e n t   t o   c a l l   t h i s   m e t h o d   ( L i s t i n g   3 ) . H  L M L l     �� N O��   N 9 3 Listing 3  A script calling the Objective-C method    O � P P f   L i s t i n g   3     A   s c r i p t   c a l l i n g   t h e   O b j e c t i v e - C   m e t h o d M  Q R Q l     ��������  ��  ��   R  S T S l     �� U V��   U   set descriptionRecord to    V � W W 2   s e t   d e s c r i p t i o n R e c o r d   t o T  X Y X l     �� Z [��   Z ^ X         {|IFPkgDescriptionTitle|:packageTitle,|IFPkgDescriptionVersion|:packageVersion,    [ � \ \ �                   { | I F P k g D e s c r i p t i o n T i t l e | : p a c k a g e T i t l e , | I F P k g D e s c r i p t i o n V e r s i o n | : p a c k a g e V e r s i o n , Y  ] ^ ] l     �� _ `��   _ 9 3         |IFPkgDescriptionDescription|:description,    ` � a a f                   | I F P k g D e s c r i p t i o n D e s c r i p t i o n | : d e s c r i p t i o n , ^  b c b l     �� d e��   d = 7         |IFPkgDescriptionDeleteWarning|:deleteWarning}    e � f f n                   | I F P k g D e s c r i p t i o n D e l e t e W a r n i n g | : d e l e t e W a r n i n g } c  g h g l     �� i j��   i F @ set rootName to call method "lastPathComponent" of rootFilePath    j � k k �   s e t   r o o t N a m e   t o   c a l l   m e t h o d   " l a s t P a t h C o m p o n e n t "   o f   r o o t F i l e P a t h h  l m l l     �� n o��   n U O set descriptionFilePath to temporaryItemsPath & rootName & "description.plist"    o � p p �   s e t   d e s c r i p t i o n F i l e P a t h   t o   t e m p o r a r y I t e m s P a t h   &   r o o t N a m e   &   " d e s c r i p t i o n . p l i s t " m  q r q l     �� s t��   s ] W call method "writeDictionary:withName:" of class "CreatePackageAction" with parameters    t � u u �   c a l l   m e t h o d   " w r i t e D i c t i o n a r y : w i t h N a m e : "   o f   c l a s s   " C r e a t e P a c k a g e A c t i o n "   w i t h   p a r a m e t e r s r  v w v l     �� x y��   x 4 .      {descriptionRecord, descriptionFilePath}    y � z z \             { d e s c r i p t i o n R e c o r d ,   d e s c r i p t i o n F i l e P a t h } w  { | { l      �� } ~��   }��
property p_projectPath : "Users:oldman:Development:GenStringResources:QOLocalizableStrings.xcodeproj"
property p_target : "QOLocalizableStrings"
property p_resultCleanFileName : "Users:oldman:Documents:Temp:cleanresult.txt"
property p_resultBuildFileName : "Users:oldman:Documents:Temp:buildresult.txt"
property p_errorOfResultBuildFileName : "Users:oldman:Documents:Temp:errorbuildresult.txt"
property p_buildConfig : "Debug"
    ~ �  X 
 p r o p e r t y   p _ p r o j e c t P a t h   :   " U s e r s : o l d m a n : D e v e l o p m e n t : G e n S t r i n g R e s o u r c e s : Q O L o c a l i z a b l e S t r i n g s . x c o d e p r o j " 
 p r o p e r t y   p _ t a r g e t   :   " Q O L o c a l i z a b l e S t r i n g s " 
 p r o p e r t y   p _ r e s u l t C l e a n F i l e N a m e   :   " U s e r s : o l d m a n : D o c u m e n t s : T e m p : c l e a n r e s u l t . t x t " 
 p r o p e r t y   p _ r e s u l t B u i l d F i l e N a m e   :   " U s e r s : o l d m a n : D o c u m e n t s : T e m p : b u i l d r e s u l t . t x t " 
 p r o p e r t y   p _ e r r o r O f R e s u l t B u i l d F i l e N a m e   :   " U s e r s : o l d m a n : D o c u m e n t s : T e m p : e r r o r b u i l d r e s u l t . t x t " 
 p r o p e r t y   p _ b u i l d C o n f i g   :   " D e b u g " 
 |  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �%
property p_projectPath : "Users:oldman:Development:Verpack:Verpack:Verpack.xcodeproj"
property p_target : "Verpack"
property p_resultCleanFileName : "Users:oldman:Documents:LocalizableStrings:Strings:LocalizableStrings:Verpack_cleanResult.txt"
property p_resultBuildFileName : "Users:oldman:Documents:LocalizableStrings:Strings:LocalizableStrings:Verpack_build.txt"
property p_errorOfResultBuildFileName : "Users:oldman:Documents:LocalizableStrings:Strings:LocalizableStrings:Verpack_errorsOfBuild.txt"
property p_buildConfig : "Development"
    � � � �> 
 p r o p e r t y   p _ p r o j e c t P a t h   :   " U s e r s : o l d m a n : D e v e l o p m e n t : V e r p a c k : V e r p a c k : V e r p a c k . x c o d e p r o j " 
 p r o p e r t y   p _ t a r g e t   :   " V e r p a c k " 
 p r o p e r t y   p _ r e s u l t C l e a n F i l e N a m e   :   " U s e r s : o l d m a n : D o c u m e n t s : L o c a l i z a b l e S t r i n g s : S t r i n g s : L o c a l i z a b l e S t r i n g s : V e r p a c k _ c l e a n R e s u l t . t x t " 
 p r o p e r t y   p _ r e s u l t B u i l d F i l e N a m e   :   " U s e r s : o l d m a n : D o c u m e n t s : L o c a l i z a b l e S t r i n g s : S t r i n g s : L o c a l i z a b l e S t r i n g s : V e r p a c k _ b u i l d . t x t " 
 p r o p e r t y   p _ e r r o r O f R e s u l t B u i l d F i l e N a m e   :   " U s e r s : o l d m a n : D o c u m e n t s : L o c a l i z a b l e S t r i n g s : S t r i n g s : L o c a l i z a b l e S t r i n g s : V e r p a c k _ e r r o r s O f B u i l d . t x t " 
 p r o p e r t y   p _ b u i l d C o n f i g   :   " D e v e l o p m e n t " 
 �  � � � l     ��������  ��  ��   �  � � � i      � � � I      �� ����� "0 runbuildproject runBuildProject �  � � � o      ���� 0 projectpath projectPath �  � � � o      ���� 0 projecttarget projectTarget �  � � � o      ���� *0 resultcleanfilename resultCleanFileName �  � � � o      ���� *0 resultbuildfilename resultBuildFileName �  � � � o      ���� 80 errorofresultbuildfilename errorOfResultBuildFileName �  ��� � o      ���� 00 buildconfigurationtype buildConfigurationType��  ��   � k    � � �  � � � q       � � ������  0 thebuildresult theBuildResult��   �  � � � q       � � ������  0 thecleanresult theCleanResult��   �  � � � q       � � ������  0 theerrorresult theErrorResult��   �  � � � r      � � � J     ����   � o      ����  0 thebuildresult theBuildResult �  � � � r    	 � � � J    ����   � o      ����  0 thecleanresult theCleanResult �  � � � r   
  � � � J   
 ����   � o      ����  0 theerrorresult theErrorResult �  � � � l   ��������  ��  ��   �  � � � O    � � � � k    � � �  � � � I   �� ���
�� .aevtodocnull  �    alis � o    ���� 0 projectpath projectPath��   �  ��� � O    � � � � k     � � �  � � � l     ��������  ��  ��   �  � � � l      �� � ���   � G Aset theBuildResult to "Analyze first.m
Analyze second.mm" as text    � � � � � s e t   t h e B u i l d R e s u l t   t o   " A n a l y z e   f i r s t . m 
 A n a l y z e   s e c o n d . m m "   a s   t e x t �  � � � l     ��������  ��  ��   �  � � � Q     � � � � � k   # � � �  � � � l  # #��������  ��  ��   �  � � � l  # #�� � ���   � ' ! set the build configuration type    � � � � B   s e t   t h e   b u i l d   c o n f i g u r a t i o n   t y p e �  � � � l  # #��������  ��  ��   �  � � � r   # & � � � m   # $��
�� 
msng � o      ���� 0 buildconfig buildConfig �  � � � r   ' 7 � � � e   ' 5 � � 6  ' 5 � � � 4   ' +�� �
�� 
buct � m   ) *����  � =  , 3 � � � 1   - /��
�� 
pnam � o   0 2���� 00 buildconfigurationtype buildConfigurationType � o      ���� 0 buildconfig buildConfig �  � � � Z   8 F � ����� � =   8 ; � � � o   8 9���� 0 buildconfig buildConfig � m   9 :��
�� 
msng � R   > B�� ���
�� .ascrerr ****      � **** � m   @ A � � � � � > C a n n o t   f i n d   b u i l d   c o n f i g u r a t i o n��  ��  ��   �  � � � r   G L � � � o   G H���� 0 buildconfig buildConfig � 1   H K��
�� 
abct �  � � � l  M M��������  ��  ��   �  � � � l  M M��������  ��  ��   �  � � � l  M M�� � ���   �   set the target    � � � �    s e t   t h e   t a r g e t �  � � � l  M M��������  ��  ��   �  � � � r   M P � � � m   M N��
�� 
msng � o      ���� 0 	thetarget 	theTarget �  �  � r   Q W 4   Q U��
�� 
tarR o   S T���� 0 projecttarget projectTarget o      ���� 0 	thetarget 	theTarget   Z   X f���� =   X [	 o   X Y���� 0 	thetarget 	theTarget	 m   Y Z��
�� 
msng R   ^ b��
��
�� .ascrerr ****      � ****
 m   ` a � $ C a n n o t   f i n d   t a r g e t��  ��  ��    r   g l o   g h���� 0 	thetarget 	theTarget 1   h k��
�� 
atar  l  m m��������  ��  ��    l  m m�������  ��  �    l  m m�~�~     clean    �    c l e a n  l  m m�}�|�{�}  �|  �{    r   m x I  m v�z�y 
�z .pbpscleeutxt       obj �y    �x!"
�x 
rpch! m   q r�w
�w boovtrue" �v!�u
�v 
rebl�u   o      �t�t 0 aresult aResult #$# r   y �%&% K   y '' �s(�r�s 	0 clean  ( o   | }�q�q 0 aresult aResult�r  & n      )*)  ;   � �* o    ��p�p  0 thecleanresult theCleanResult$ +,+ l  � ��o�n�m�o  �n  �m  , -.- l  � ��l�k�j�l  �k  �j  . /0/ l  � ��i12�i  1   build   2 �33    b u i l d0 454 l  � ��h�g�f�h  �g  �f  5 676 l  � ��e89�e  8 < 6set aResult to build using buildConfig with transcript   9 �:: l s e t   a R e s u l t   t o   b u i l d   u s i n g   b u i l d C o n f i g   w i t h   t r a n s c r i p t7 ;<; l  � ��d=>�d  = 4 .set end of theBuildResult to {|build|:aResult}   > �?? \ s e t   e n d   o f   t h e B u i l d R e s u l t   t o   { | b u i l d | : a R e s u l t }< @A@ l  � ��c�b�a�c  �b  �a  A BCB l  � ��`DE�`  D ' !set kind to build message warning   E �FF B s e t   k i n d   t o   b u i l d   m e s s a g e   w a r n i n gC GHG l  � ��_IJ�_  I , &set message to build message theResult   J �KK L s e t   m e s s a g e   t o   b u i l d   m e s s a g e   t h e R e s u l tH LML l  � ��^NO�^  N , &set theResult to build (build message)   O �PP L s e t   t h e R e s u l t   t o   b u i l d   ( b u i l d   m e s s a g e )M QRQ l  � ��]ST�]  S E ?set theResult to debug the active executable of myProject --new   T �UU ~ s e t   t h e R e s u l t   t o   d e b u g   t h e   a c t i v e   e x e c u t a b l e   o f   m y P r o j e c t   - - n e wR V�\V l  � ��[�Z�Y�[  �Z  �Y  �\   � R      �XW�W
�X .ascrerr ****      � ****W o      �V�V 0 m  �W   � r   � �XYX b   � �Z[Z m   � �\\ �]]  E x c e p t i o n :  [ o   � ��U�U 0 m  Y o      �T�T  0 theerrorresult theErrorResult � ^�S^ l  � ��R_`�R  _ 
 quit   ` �aa  q u i t�S   � 4    �Qb
�Q 
projb o    �P�P 0 projecttarget projectTarget��   � m    cc�                                                                                  xcde  alis    `  Macintosh HD               �=H+   	�	Xcode.app                                                       �����>�        ����  	                Applications    ��      ���     	� 	�  -Macintosh HD:Developer:Applications:Xcode.app    	 X c o d e . a p p    M a c i n t o s h   H D   Developer/Applications/Xcode.app  / ��   � ded l  � ��O�N�M�O  �N  �M  e fgf Z   � �hi�L�Kh >  � �jkj o   � ��J�J  0 thecleanresult theCleanResultk J   � ��I�I  i k   � �ll mnm r   � �opo o   � ��H�H *0 resultcleanfilename resultCleanFileNamep o      �G�G 0 filename fileNamen qrq r   � �sts I  � ��Fuv
�F .rdwropenshor       fileu o   � ��E�E 0 filename fileNamev �Dw�C
�D 
permw m   � ��B
�B boovtrue�C  t o      �A�A "0 cleanresultfile cleanResultFiler xyx I  � ��@z{
�@ .rdwrwritnull���     ****z o   � ��?�?  0 thecleanresult theCleanResult{ �>|�=
�> 
refn| o   � ��<�< "0 cleanresultfile cleanResultFile�=  y }�;} I  � ��:~�9
�: .rdwrclosnull���     ****~ o   � ��8�8 "0 cleanresultfile cleanResultFile�9  �;  �L  �K  g � l  � ��7�6�5�7  �6  �5  � ��� Z   � ����4�3� >  � ���� o   � ��2�2  0 theerrorresult theErrorResult� J   � ��1�1  � k   � ��� ��� r   � ���� o   � ��0�0 80 errorofresultbuildfilename errorOfResultBuildFileName� o      �/�/ 0 filename fileName� ��� r   � ���� I  � ��.��
�. .rdwropenshor       file� o   � ��-�- 0 filename fileName� �,��+
�, 
perm� m   � ��*
�* boovtrue�+  � o      �)�) 00 errorofbuildresultfile errorOfBuildResultFile� ��� I  � ��(��
�( .rdwrwritnull���     ****� o   � ��'�'  0 theerrorresult theErrorResult� �&��%
�& 
refn� o   � ��$�$ 00 errorofbuildresultfile errorOfBuildResultFile�%  � ��#� I  � ��"��!
�" .rdwrclosnull���     ****� o   � �� �  00 errorofbuildresultfile errorOfBuildResultFile�!  �#  �4  �3  � ��� l  � �����  �  �  � ��� l  � �����  �  �  � ��� l  � �����  �   parse result of building   � ��� 2   p a r s e   r e s u l t   o f   b u i l d i n g� ��� l  � �����  �  �  � ��� Z   ������� >  � ���� o   � ���  0 thebuildresult theBuildResult� J   � ���  � k   ���� ��� r   � ���� m   � ��
� 
msng� o      �� 0 	theresult 	theResult� ��� r   ���� n  ���� 1   ��
� 
txdl� 1   � ��
� 
ascr� o      �� 0 	old_delim  � ��� r  ��� m  
�� ���  
� n     ��� 1  �
� 
txdl� 1  
�
� 
ascr� ��� r  ��� n  ��� 2  �

�
 
citm� o  �	�	  0 thebuildresult theBuildResult� l     ���� o      �� 0 stringslist stringsList�  �  � ��� l ����  �  �  � ��� l ����  �  log (stringsList count)   � ��� . l o g   ( s t r i n g s L i s t   c o u n t )� ��� l �� ���  �   ��  � ��� X  ������ k  3��� ��� l 33��������  ��  ��  � ��� l 33������  �  log (loopVariable)   � ��� $ l o g   ( l o o p V a r i a b l e )� ��� l 33��������  ��  ��  � ��� l 33������  � 5 /set the wordsList to every word of loopVariable   � ��� ^ s e t   t h e   w o r d s L i s t   t o   e v e r y   w o r d   o f   l o o p V a r i a b l e� ��� r  3>��� 1  36��
�� 
spac� n     ��� 1  9=��
�� 
txdl� 1  69��
�� 
ascr� ��� r  ?J��� n  ?F��� 2 BF��
�� 
citm� o  ?B���� 0 loopvariable loopVariable� l     ������ o      ���� 0 	wordslist 	wordsList��  ��  � ���� Z  K�������� = KT��� l KR������ I KR�����
�� .corecnte****       ****� o  KN���� 0 	wordslist 	wordsList��  ��  ��  � m  RS���� � k  W��� ��� r  Wc��� n  W_��� 4  Z_���
�� 
cobj� m  ]^���� � o  WZ���� 0 	wordslist 	wordsList� o      ���� 0 	firstword 	firstWord� ��� l dd��������  ��  ��  � � � l dd����   ! log ("!" & firstWord & ";")    � 6 l o g   ( " ! "   &   f i r s t W o r d   &   " ; " )   l dd��������  ��  ��   �� Z  d����� = dk	
	 o  dg���� 0 	firstword 	firstWord
 m  gj �  A n a l y z e k  n�  r  nz n  nv 4  qv��
�� 
cobj m  tu����  o  nq���� 0 	wordslist 	wordsList o      ���� 0 
secondword 
secondWord  l {{����    log (secondWord)    �   l o g   ( s e c o n d W o r d )  r  {� o  {~���� 0 
secondword 
secondWord n        ;  �� o  ~����� 0 	theresult 	theResult  ��  r  ��!"! m  ��## �$$  
" n      %&%  ;  ��& o  ������ 0 	theresult 	theResult��  ��  ��  ��  ��  ��  ��  �� 0 loopvariable loopVariable� o   #���� 0 stringslist stringsList� '(' r  ��)*) o  ������ 0 	old_delim  * n     +,+ 1  ����
�� 
txdl, 1  ����
�� 
ascr( -.- l ����������  ��  ��  . /0/ r  ��121 o  ������ *0 resultbuildfilename resultBuildFileName2 o      ���� 0 filename fileName0 343 r  ��565 I ����78
�� .rdwropenshor       file7 o  ������ 0 filename fileName8 ��9��
�� 
perm9 m  ����
�� boovtrue��  6 o      ���� "0 buildresultfile buildResultFile4 :;: r  ��<=< c  ��>?> o  ������ 0 	theresult 	theResult? m  ����
�� 
utxt= o      ���� 0 	theresult 	theResult; @A@ I ����BC
�� .rdwrwritnull���     ****B o  ������  0 thebuildresult theBuildResultC ��D��
�� 
refnD o  ������ "0 buildresultfile buildResultFile��  A E��E I ����F��
�� .rdwrclosnull���     ****F o  ������ "0 buildresultfile buildResultFile��  ��  �  �  � G��G L  ��HH m  ������ ��   � IJI l     ��������  ��  ��  J KLK l     ��������  ��  ��  L MNM l     ��OP��  O � �runBuildProject(p_projectPath, p_target, p_resultCleanFileName, p_resultBuildFileName, p_errorOfResultBuildFileName, p_buildConfig)   P �QQ r u n B u i l d P r o j e c t ( p _ p r o j e c t P a t h ,   p _ t a r g e t ,   p _ r e s u l t C l e a n F i l e N a m e ,   p _ r e s u l t B u i l d F i l e N a m e ,   p _ e r r o r O f R e s u l t B u i l d F i l e N a m e ,   p _ b u i l d C o n f i g )N R��R l     ��������  ��  ��  ��       ��ST��  S ���� "0 runbuildproject runBuildProjectT �� �����UV���� "0 runbuildproject runBuildProject�� ��W�� W  �������������� 0 projectpath projectPath�� 0 projecttarget projectTarget�� *0 resultcleanfilename resultCleanFileName�� *0 resultbuildfilename resultBuildFileName�� 80 errorofresultbuildfilename errorOfResultBuildFileName�� 00 buildconfigurationtype buildConfigurationType��  U �������������������������������������������������� 0 projectpath projectPath�� 0 projecttarget projectTarget�� *0 resultcleanfilename resultCleanFileName�� *0 resultbuildfilename resultBuildFileName�� 80 errorofresultbuildfilename errorOfResultBuildFileName�� 00 buildconfigurationtype buildConfigurationType��  0 thebuildresult theBuildResult��  0 thecleanresult theCleanResult��  0 theerrorresult theErrorResult�� 0 buildconfig buildConfig�� 0 	thetarget 	theTarget�� 0 aresult aResult�� 0 m  �� 0 filename fileName�� "0 cleanresultfile cleanResultFile�� 00 errorofbuildresultfile errorOfBuildResultFile�� 0 	theresult 	theResult�� 0 	old_delim  �� 0 stringslist stringsList�� 0 loopvariable loopVariable�� 0 	wordslist 	wordsList�� 0 	firstword 	firstWord�� 0 
secondword 
secondWord�� "0 buildresultfile buildResultFileV $c��~�}�|X�{ ��z�y�x�w�v�u�t�s�r�q\�p�o�n�m�l�k�j��i�h�g�f�e#�d
� .aevtodocnull  �    alis
�~ 
proj
�} 
msng
�| 
buctX  
�{ 
pnam
�z 
abct
�y 
tarR
�x 
atar
�w 
rpch
�v 
rebl�u 
�t .pbpscleeutxt       obj �s 	0 clean  �r 0 m  �q  
�p 
perm
�o .rdwropenshor       file
�n 
refn
�m .rdwrwritnull���     ****
�l .rdwrclosnull���     ****
�k 
ascr
�j 
txdl
�i 
citm
�h 
kocl
�g 
cobj
�f .corecnte****       ****
�e 
spac
�d 
utxt���jvE�OjvE�OjvE�O� ��j O*�/ w f�E�O*�k/�[�,\Z�81EE�O��  	)j�Y hO�*�,FO�E�O*�/E�O��  	)j�Y hO�*�,FO*�e�e� E�Oa �l�6FOPW X  a �%E�OPUUO�jv $�E�O�a el E�O�a �l O�j Y hO�jv $�E�O�a el E�O�a �l O�j Y hO�jv ��E^ O_ a ,E^ Oa _ a ,FO�a -E^ O {] [a a l kh _  _ a ,FO] a -E^ O] j l  >] a k/E^ O] a !  #] a l/E^ O] ] 6FOa "] 6FY hY h[OY��O] _ a ,FO�E�O�a el E^ O] a #&E^ O�a ] l O] j Y hOkascr  ��ޭ