// 加速度センサのx軸に接続したアナログピンの番号
const int xAxisPin = 0;

// 加速度センサのy軸に接続したアナログピンの番号
const int yAxisPin = 1;

void setup() {
  // シリアル通信を開始
  Serial.begin(9600);
}

void loop() {
  // x軸とy軸の値を読み取る
  int xAxisValue = analogRead(xAxisPin);
  int yAxisValue = analogRead(yAxisPin);

  // 読み取った値を-1から1までの範囲にスケーリングしてsinθの値とする
  float xAxisSinTheta = mapInFloat(xAxisValue, 306, 716, -1, 1);
  float yAxisSinTheta = mapInFloat(yAxisValue, 306, 716, -1, 1);

  // それぞれの値を-1から1までの範囲に制限する
  xAxisSinTheta = constrain(xAxisSinTheta, -1, 1);
  yAxisSinTheta = constrain(yAxisSinTheta, -1, 1);

  // 逆サインを求めた結果（単位はラジアン）を度に変換
  int xAxisTilt = floor(asin(xAxisSinTheta) * 180 / PI);
  int yAxisTilt = floor(asin(yAxisSinTheta) * 180 / PI);

  // それぞれの軸の値をプリント
  Serial.print("x: ");
  Serial.print(xAxisTilt);
  Serial.print(", y: ");
  Serial.print(yAxisTilt);
  Serial.println();

  // 次のループ開始までに200ms待つ
  delay(200);
}

// 標準で用意されているmapは引数と戻り値の型がlongである
// 今回は-1から1までにスケーリングする必要があるためfloatで同じ計算をする
float mapInFloat(float x, float iMin, float iMax,
                 float oMin, float oMax) {
  return (x - iMin) * (oMax - oMin) / (iMax - iMin) + oMin;
}

