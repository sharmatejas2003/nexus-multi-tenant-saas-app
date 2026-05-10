package com.app.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface TenantSecure {
//	com.app.annotation.TenantSecure is a Marker Annotation. It is supposed to be empty! Its only job is to exist so the SecurityAspect can find the methods you want to protect.
}