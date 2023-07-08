package com.hanaonestock.member.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Map;

@Controller
@RequestMapping("/oauth")
public class KakaoOAuth2Controller {
    @GetMapping("/loginInfo")
    //현재 사용자의 인증 정보를 나타내며, 주로 사용자가 인증되었는지 확인하거나 사용자의 권한을 확인하는 데 사용
    public String getJson(Authentication authentication) {
        //현재 인증된 사용자의 주요 정보를 반환
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        Map<String, Object> attributes = oAuth2User.getAttributes();

        //return attributes.toString();
        return "redirect:/";
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request, Authentication authentication) {

        if (authentication != null && authentication.isAuthenticated()) {
            // OAuth2 인증 토큰인 경우
            if (authentication instanceof OAuth2AuthenticationToken) {
                OAuth2AuthenticationToken oauthToken = (OAuth2AuthenticationToken) authentication;
                String provider = oauthToken.getAuthorizedClientRegistrationId();
                if ("kakao".equals(provider)) {
                    // 세션 무효화
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        session.invalidate();
                    }
                    // 카카오 계정 로그아웃 URL로 리다이렉트
                    return "redirect:https://kauth.kakao.com/oauth/logout?client_id=3e04da871b237fb6169d1ec2b50af7fb&logout_redirect_uri=http%3A%2F%2Flocalhost%3A8080%2F";

                }
            }
            // 일반적인 로그아웃 처리
        }
        return "redirect:/";
    }


}