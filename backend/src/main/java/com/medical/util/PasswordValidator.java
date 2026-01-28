package com.medical.util;

import lombok.Getter;

/**
 * 密码强度验证工具类
 * 
 * @author AI Medical Team
 */
public class PasswordValidator {

    /**
     * 密码强度枚举
     */
    public enum Strength {
        WEAK(0, "弱", "red"),
        MEDIUM(1, "中", "orange"),
        STRONG(2, "强", "green");

        @Getter
        private final int level;

        @Getter
        private final String label;

        @Getter
        private final String color;

        Strength(int level, String label, String color) {
            this.level = level;
            this.label = label;
            this.color = color;
        }
    }

    /**
     * 验证密码强度
     * 
     * @param password 密码
     * @return 密码强度
     */
    public static Strength validateStrength(String password) {
        if (password == null || password.length() < 8) {
            return Strength.WEAK;
        }

        int score = 0;

        // 长度检查
        if (password.length() >= 8) {
            score++;
        }
        if (password.length() >= 12) {
            score++;
        }

        // 包含小写字母
        if (password.matches(".*[a-z].*")) {
            score++;
        }

        // 包含大写字母
        if (password.matches(".*[A-Z].*")) {
            score++;
        }

        // 包含数字
        if (password.matches(".*\\d.*")) {
            score++;
        }

        // 包含特殊字符
        if (password.matches(".*[@$!%*?&].*")) {
            score++;
        }

        // 根据分数判断强度
        if (score >= 5) {
            return Strength.STRONG;
        } else if (score >= 3) {
            return Strength.MEDIUM;
        } else {
            return Strength.WEAK;
        }
    }

    /**
     * 验证密码是否符合要求
     * 
     * @param password 密码
     * @return 是否符合要求
     */
    public static boolean isValid(String password) {
        if (password == null || password.length() < 8 || password.length() > 20) {
            return false;
        }

        // 必须包含大小写字母、数字和特殊字符
        return password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,20}$");
    }

    /**
     * 获取密码强度提示信息
     * 
     * @param password 密码
     * @return 提示信息
     */
    public static String getStrengthMessage(String password) {
        Strength strength = validateStrength(password);
        return "密码强度: " + strength.getLabel();
    }

    /**
     * 检查两次密码是否一致
     * 
     * @param password 密码
     * @param confirmPassword 确认密码
     * @return 是否一致
     */
    public static boolean isPasswordMatch(String password, String confirmPassword) {
        if (password == null || confirmPassword == null) {
            return false;
        }
        return password.equals(confirmPassword);
    }
}
