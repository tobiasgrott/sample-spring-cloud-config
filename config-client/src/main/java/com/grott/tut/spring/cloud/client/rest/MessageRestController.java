package com.grott.tut.spring.cloud.client.rest;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RefreshScope
public class MessageRestController {
    @Value("${message:Hello default}")
    private String message;

    @Value("${user.password}")
    private String encryptedPassword;

    @RequestMapping("/message")
    String getMessage(){
        return this.message;
    }
    @RequestMapping("/encryptedPassword")
    public String getEncryptedPassword(){
        return encryptedPassword;
    }
}
