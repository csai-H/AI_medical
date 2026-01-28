package com.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.medical.entity.Role;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 角色Mapper接口
 *
 * @author AI Medical Team
 */
@Mapper
public interface RoleMapper extends BaseMapper<Role> {

    /**
     * 根据用户ID获取角色编码列表
     *
     * @param userId 用户ID
     * @return 角色编码列表
     */
    @Select("SELECT r.role_code " +
            "FROM sys_role r " +
            "INNER JOIN sys_user_role ur ON r.id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND r.status = 1 AND r.deleted = 0")
    List<String> getRoleCodesByUserId(@Param("userId") Long userId);

    /**
     * 根据用户ID获取角色列表
     *
     * @param userId 用户ID
     * @return 角色列表
     */
    @Select("SELECT r.* " +
            "FROM sys_role r " +
            "INNER JOIN sys_user_role ur ON r.id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND r.status = 1 AND r.deleted = 0")
    List<Role> getRolesByUserId(@Param("userId") Long userId);

    /**
     * 根据角色编码获取角色
     *
     * @param roleCode 角色编码
     * @return 角色对象
     */
    @Select("SELECT * FROM sys_role WHERE role_code = #{roleCode} AND deleted = 0")
    Role getRoleByRoleCode(@Param("roleCode") String roleCode);
}
