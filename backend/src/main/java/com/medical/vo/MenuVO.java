package com.medical.vo;

import lombok.Data;

import java.util.List;

/**
 * 菜单视图对象
 *
 * @author AI Medical Team
 */
@Data
public class MenuVO {

    /**
     * 父权限ID
     */
    private Long parentId;

    /**
     * 权限ID
     */
    private Long id;

    /**
     * 权限编码
     */
    private String permissionCode;

    /**
     * 权限名称
     */
    private String permissionName;

    /**
     * 菜单类型: directory/menu/button
     */
    private String menuType;

    /**
     * 菜单图标
     */
    private String icon;

    /**
     * 路由路径
     */
    private String path;

    /**
     * 前端组件路径
     */
    private String component;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 是否可见: 0-隐藏, 1-显示
     */
    private Integer visible;

    /**
     * 子菜单列表
     */
    private List<MenuVO> children;
}
