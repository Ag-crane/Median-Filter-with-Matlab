
%% Input 이미지 준비

% 이미지 로드
inputImage = imread('ultrasound_b_mode_image_2D.jpg');

% 이미지 크기 추출
[rows, cols, ~] = size(inputImage);

% 노이즈 추가
noiseLevel = 30;

% 가우시안 노이즈 생성
randomNoise = noiseLevel * randn(rows, cols);

% 원본 이미지와 가우시안 노이즈를 합성하여 노이즈가 추가된 이미지 생성
noisyImage = double(inputImage) + randomNoise;

% 픽셀 값 범위를 0에서 255 사이로 제한
noisyImage = uint8(max(0, min(255, noisyImage)));

% 필터 크기에 따른 성능 측정을 위한 변수 초기화
filterSize = [3,5,7,9];
mse_values = zeros(size(filterSize));
snr_values = zeros(size(filterSize));
psnr_values = zeros(size(filterSize));
ad_values = zeros(size(filterSize));
si_values = zeros(size(filterSize));

%% 원본 이미지와 노이즈가 추가된 이미지 출력
figure;
subplot(2,4,2)
imshow(inputImage)
title('Original Image')
subplot(2,4,3)
imshow(noisyImage)
title('Speckled Image')

%% median filter 적용
for i = 1:4

    % 필터 적용을 위한 이미지 패딩
    padding = ( filterSize(i)-1 ) / 2 ;
    paddedImage = padarray(noisyImage, [padding, padding], 'replicate');

    % 결과 이미지 초기화
    outputImage = zeros(size(inputImage));

    % 필터 적용
    for j = 1:rows
        for k = 1:cols
            % 주변 픽셀 값 추출
            neighbors = paddedImage(j:(j+filterSize(i)-1), k:(k+filterSize(i)-1));
            
            % 중간값 계산
            sorted_neighbors = sort(neighbors(:));
            median_value = sorted_neighbors(floor(numel(sorted_neighbors)/2) + 1);
            
            % 결과 이미지에 중간값 할당
            outputImage(j, k) = median_value;
        end
    end
    outputImage = uint8(max(0, min(255, outputImage)));
    
    % 필터링된 이미지 출력
    subplot(2,4,i+4);
    imshow(outputImage)
    title("filter Size : " + filterSize(i)+" x "+filterSize(i))
    
    % 이미지를 double 형식으로 변환
    noisyImage_double = double(noisyImage);
    outputImage_double = double(outputImage);
    
    % MSE 계산
    diff = noisyImage_double - outputImage_double;
    mse = sum(diff(:).^2) / numel(noisyImage);

    % SNR 계산
    noise = noisyImage_double - outputImage_double;
    signalPower = sum(noisyImage_double(:).^2) / numel(noisyImage_double);
    noisePower = sum(noise(:).^2) / numel(noisyImage_double);
    snr = 10 * log10(signalPower / noisePower);
    
    % PSNR 계산
    maxIntensity = max(noisyImage_double(:));
    psnr = 10 * log10(maxIntensity^2 / mse);
    
    % AD (Average Difference) 계산
    ad = sum(abs(diff(:))) / numel(noisyImage_double);
    
    % SI (Speckle Index) 계산
    mean_intensity = mean(noisyImage_double(:));
    si = std(diff(:)) / mean_intensity;
    
    mse_values(i) = mse;
    snr_values(i) = snr;
    psnr_values(i) = psnr;
    ad_values(i) = ad;
    si_values(i) = si; 

end

%% 계산한 메트릭 시각화
figure;

% MSE 그래프
subplot(2, 3, 1);
plot(filterSize, mse_values, '-o', 'LineWidth', 2);
xlabel('filter size');
ylabel('MSE');

% AD 그래프
subplot(2, 3, 2);
plot(filterSize, ad_values, '-o', 'LineWidth', 2);
xlabel('filter size');
ylabel('AD');

% SI 그래프
subplot(2, 3, 3);
plot(filterSize, si_values, '-o', 'LineWidth', 2);
xlabel('filter size');
ylabel('SI');

% SNR 그래프
subplot(2, 3, 4);
plot(filterSize, snr_values, '-o', 'LineWidth', 2);
xlabel('filter size');
ylabel('SNR');

% PSNR 그래프
subplot(2, 3, 5);
plot(filterSize, psnr_values, '-o', 'LineWidth', 2);
xlabel('filter size');
ylabel('PSNR');