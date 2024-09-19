package com.example.yourproject;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration  // 이 클래스가 설정 파일임을 알려줌
public class MyConfig {

    @Bean  // Spring에서 관리하는 빈(Bean) 설정
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")  // 모든 경로에 대해 CORS 허용
                        .allowedOrigins("*")  // 프론트엔드 도메인
                        .allowedMethods("GET", "POST", "PUT", "DELETE")  // 허용할 HTTP 메서드
                        .allowedHeaders("*");  // 모든 헤더 허용
            }
        };
    }
}

