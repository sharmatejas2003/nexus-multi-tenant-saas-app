package com.app.repository;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.app.entity.Project;

@Repository
public class JdbcProjectRepository{
	private final JdbcTemplate template;
	
	public JdbcProjectRepository(JdbcTemplate template) {
		this.template=template;
	}
	
	public List<Project>findAll(){
		return template.query("SELECT * FROM project",
	            (rs, rowNum) -> {
	                Project p = new Project();
	                p.setId(rs.getString("id"));
	                p.setName(rs.getString("name"));
	                return p;
	            }
	            );
	}	
}
