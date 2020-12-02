%struct.__sFILE = type { i8*, i32, i32, i16, i16, %struct.__sbuf, i32, i8*, i32 (i8*)*, i32 (i8*, i8*, i32)*, i64 (i8*, i64, i32)*, i32 (i8*, i8*, i32)*, %struct.__sbuf, %struct.__sFILEX*, i32, [3 x i8], [1 x i8], %struct.__sbuf, i32, i64 }
%struct.__sFILEX = type opaque
%struct.__sbuf = type { i8*, i32 }

@.str = private unnamed_addr constant [4 x i8] c"%u\0A\00", align 1
@intpp = private unnamed_addr constant [4 x i8] c"%i\0a\00", align 1  ;; intの中身を見る用
@test_str = private unnamed_addr constant [6 x i8] c"hoge\0a\00", align 1  ;; printfデバッグ用
@str1 = private unnamed_addr constant [50 x i8] c"契約書だよ。そこに名前を書きな。\0a\00", align 1
@str2 = private unnamed_addr constant [58 x i8] c"フン。%sというのかい。贅沢な名だねぇ。\0a\00", align 1
@str3 = private unnamed_addr constant [5 x i8] c"test\00", align 1
@str4 = private unnamed_addr constant [106 x i8] c"今からお前の名前は%sだ。いいかい、%sだよ。分かったら返事をするんだ、%s!!\0A\00", align 1
@__stdinp = external global %struct.__sFILE*, align 8

define void @rtrim(i8*) {
start:
  %1 = alloca i8*, align 8  ;; pointer
  %2 = alloca i32, align 4  ;; int i
  store i8* %0, i8** %1, align 8
  store i32 0, i32* %2, align 4  ;; i = 0
  br label %loop_start
loop_start:
  %3 = load i8*, i8** %1, align 8 ;; str
  %4 = load i32, i32* %2, align 4
  %5 = getelementptr inbounds i8, i8* %3, i32 %4
  %6 = load i8, i8* %5, align 1
  %7 = sext i8 %6 to i32
  %test = icmp ne i32 %7, 10  ;; 改行かどうか調べる
  br i1 %test, label %then, label %else
then:
  %8 = load i32, i32* %2, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %2, align 4  ;; ++i
  br label %loop_start
else:
  %10 = load i8*, i8** %1, align 8
  %11 = load i32, i32* %2, align 4
  %12 = getelementptr inbounds i8, i8* %10, i32 %11
  store i8 0, i8* %12, align 1
  ret void
}

define i32 @strLen(i8*) {
start:
  %1 = alloca i8*, align 8  ;; pointer
  %2 = alloca i32, align 4  ;; int i
  store i8* %0, i8** %1, align 8
  store i32 0, i32* %2, align 4  ;; i = 0
  br label %loop_start
loop_start:
  %3 = load i8*, i8** %1, align 8 ;; str
  %4 = load i32, i32* %2, align 4
  %5 = getelementptr inbounds i8, i8* %3, i32 %4
  %6 = load i8, i8* %5, align 1
  %7 = sext i8 %6 to i32
  %test = icmp ne i32 %7, 0  ;; check %7 is \0
  br i1 %test, label %then, label %else
then:
  %8 = load i32, i32* %2, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %2, align 4  ;; ++i
  br label %loop_start
else:
  %10 = load i32, i32* %2, align 4
  ret i32 %10  ; return i
}

define i32 @mbStrLen(i8*) {
start:
  %1 = alloca i8*, align 8  ;; pointer
  %count = alloca i32, align 4
  store i8* %0, i8** %1, align 8
  store i32 0, i32* %count, align 4  ;; count = 0
  br label %loop_start
loop_start:
  %2 = load i8*, i8** %1, align 8 ;; str
  %3 = getelementptr inbounds i8, i8* %2, i32 0
  %4 = load i8, i8* %3, align 1
  %test = icmp ne i8 %4, 0  ;; check %4 is \0
  br i1 %test, label %then, label %else
then:
  %5 = load i8*, i8** %1, align 8
  %6 = getelementptr inbounds i8, i8* %5, i32 1
  store i8* %6, i8** %1, align 8  ;; ++str
  %7 = and i8 %4, 192  ;; and %4 0xc0
  %test2 = icmp ne i8 %7, 128  ;; check 0x80
  br i1 %test2, label %then2, label %loop_start
then2:
  %8 = load i32, i32* %count, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %count, align 4  ;; ++count
  br label %loop_start
else:
  %10 = load i32, i32* %count, align 4
  ret i32 %10  ; return count
}

; 名前を奪う
define i8* @substr(i8*, i32, i32) {
  %4 = getelementptr inbounds i8, i8* %0, i32 %1  ;; offset
  %5 = getelementptr inbounds i8, i8* %4, i32 %2  ;; offset + length
  store i8 0, i8* %5, align 1 ;; \0を書き込んで文字列が終わったことにする
  ret i8* %4
}

define i32 @xorshift32(i32) {
  %2 = shl i32 %0, 13
  %3 = xor i32 %0, %2
  %4 = ashr i32 %3, 17
  %5 = xor i32 %3, %4
  %6 = shl i32 %5, 5
  %7 = xor i32 %5, %6
  ret i32 %7
}

define i32 @getRand(i32) {
  %2 = call i64 @time(i64* null)
  %3 = trunc i64 %2 to i32  ;; toInt32. 32bitを超えた分は無視.
  %4 = call i32 @xorshift32(i32 %3)
  %5 = urem i32 %4, %0  ;; %0未満の乱数を返す. unsigned intの剰余であることに注意.
  ret i32 %5
}

define i32 @main(i32, i8**) {
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([50 x i8], [50 x i8]* @str1, i32 0, i32 0))
  %4 = alloca [256 x i8], align 16  ;; buffer
  %5 = getelementptr inbounds [256 x i8], [256 x i8]* %4, i32 0, i32 0
  %6 = load %struct.__sFILE*, %struct.__sFILE** @__stdinp, align 8  ;; stdin
  call i8* @fgets(i8* %5, i32 256, %struct.__sFILE* %6)
  call void @rtrim(i8* %5)  ;; fgetsしたときの\nを取り除く
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([58 x i8], [58 x i8]* @str2, i32 0, i32 0), i8* %5)
  %9 = call i32 @strLen(i8* %5)  ;; 文字列の長さを取る
  ;%test = call i32 @mbStrLen(i8* %5)  ;; 文字列の長さを取る
  %10 = call i32 @getRand(i32 %9)  ;; 乱数生成
  call void @pp(i8* %5) ;; prettyprint
  %11 = call i8* @substr(i8* %5, i32 %10, i32 1)  ;; 名前を奪う
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([106 x i8], [106 x i8]* @str4, i32 0, i32 0), i8* %11, i8* %11, i8* %11)
  ;call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @intpp, i32 0, i32 0), i32 %test)
  ret i32 0
}

declare i32 @printf(i8*, ...)
declare i8* @fgets(i8*, i32, %struct.__sFILE*)
declare i64 @time(i64*)




define void @int_pp(i32) {
  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @intpp, i32 0, i32 0), i32 %0)
  ret void
}

define void @pp(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca i32, align 4
  store i8* %0, i8** %2, align 8
  store i32 0, i32* %3, align 4
  br label %4

; <label>:4:                                      ; preds = %12, %1
  %5 = load i8*, i8** %2, align 8
  %6 = load i32, i32* %3, align 4
  %7 = sext i32 %6 to i64
  %8 = getelementptr inbounds i8, i8* %5, i64 %7
  %9 = load i8, i8* %8, align 1
  %10 = sext i8 %9 to i32
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %12, label %22

; <label>:12:                                     ; preds = %4
  %13 = load i8*, i8** %2, align 8
  %14 = load i32, i32* %3, align 4
  %15 = sext i32 %14 to i64
  %16 = getelementptr inbounds i8, i8* %13, i64 %15
  %17 = load i8, i8* %16, align 1
  %18 = sext i8 %17 to i32
  %19 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i32 0, i32 0), i8 %17)
  %20 = load i32, i32* %3, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %3, align 4
  br label %4

; <label>:22:                                     ; preds = %4
  ret void
}
