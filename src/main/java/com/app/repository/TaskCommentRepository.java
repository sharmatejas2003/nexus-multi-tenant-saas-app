package com.app.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.app.entity.TaskComment;

public interface TaskCommentRepository extends JpaRepository<TaskComment, Long> {
	List<TaskComment> findByTaskIdOrderByCreatedAtAsc(Long taskId);
    long countByTaskId(Long taskId);

}
