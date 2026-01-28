package com.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.medical.entity.Permission;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;

import java.util.List;

/**
 * 权限Mapper接口
 *
 * @author AI Medical Team
 */
@Mapper
public interface PermissionMapper extends BaseMapper<Permission> {

    /**
     * 根据角色ID获取权限编码列表
     *
     * @param roleId 角色ID
     * @return 权限编码列表
     */
    @Select("SELECT p.permission_code " +
            "FROM sys_permission p " +
            "INNER JOIN sys_role_permission rp ON p.id = rp.permission_id " +
            "WHERE rp.role_id = #{roleId} AND p.status = 1")
    List<String> getPermissionCodesByRoleId(@Param("roleId") Integer roleId);

    /**
     * 删除角色的所有权限
     *
     * @param roleId 角色ID
     */
    @Delete("DELETE FROM sys_role_permission WHERE role_id = #{roleId}")
    void deleteRolePermissions(@Param("roleId") Integer roleId);

    /**
     * 批量插入角色权限
     *
     * @param roleId 角色ID
     * @param permissionIds 权限ID列表
     */
    @Insert("<script>" +
            "INSERT INTO sys_role_permission (role_id, permission_id) VALUES " +
            "<foreach collection='permissionIds' item='permissionId' separator=','>" +
            "(#{roleId}, #{permissionId})" +
            "</foreach>" +
            "</script>")
    void insertRolePermissions(@Param("roleId") Integer roleId, @Param("permissionIds") List<Long> permissionIds);

    /**
     * 根据角色ID获取权限ID列表
     *
     * @param roleId 角色ID
     * @return 权限ID列表
     */
    @Select("SELECT permission_id FROM sys_role_permission WHERE role_id = #{roleId}")
    List<Long> getPermissionIdsByRoleId(@Param("roleId") Integer roleId);
}
