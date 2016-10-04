<%--
  Created by IntelliJ IDEA.
  User: yhwang131
  Date: 2016-09-13
  Time: 오후 2:30
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
	<title>메뉴 설정</title>
</head>
<body ng-app="categoryApp">
	<div class="ui internally celled grid" ng-controller="categoryCtrl">
		<div class="ui modal small">
			<div class="header">Update Category Settings</div>
			<div class="content">
				<div class="ui form">
					<h4 class="ui dividing header" ng-bind="popupData==null?'Add':'Config'"></h4>
					<div class="field">
						<label>Category Name</label>
						<div class="ui input">
							<input type="text" id="category_name" ng-model="popupData.category_name">
						</div>
					</div>
					<div class="field">
						<label for="permission">Permission</label>
						<select id="permission" class="ui dropdown" ng-model="popupData.access_role">
							<option ng-repeat="role in roleList" value="{{role.cd}}">{{role.cd_name}}</option>
						</select>
					</div>
				</div>
			</div>
			<div class="actions">
				<div class="ui negative button">Cancel</div>
				<div class="ui positive right labeled icon button">
					Save
					<i class="checkmark icon"></i>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="four wide column">
				<div class="ui list">
					<div class="item" ng-repeat="firstDep in tree">
						<i class="red folder icon"></i>
						<div class="content">
							<div class="header" ng-bind="firstDep.category_name"></div>
							<div class="list">
								<div class="item" ng-repeat="secondDep in firstDep.children">
									<i class="orange file icon"></i>
									<div class="content">
										<div class="header" ng-bind="secondDep.category_name"></div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="six wide column">
				<table class="ui compact selectable celled definition table">
					<thead class="full-width">
						<tr>
							<th><div class="ui red ribbon label">1st</div></th>
							<th>카테고리</th>
							<th>보기 권한</th>
							<th>활성화</th>
						</tr>
					</thead>
					<tbody>
						<tr ng-repeat="item in firstDepthCategory">
							<td class="center aligned">
								<div class="field">
									<div class="ui radio checkbox">
										<input type="radio" name="1stChk" tabindex="0" class="hidden" value="{{$index}}"/>
										<label></label>
									</div>
								</div>
							</td>
							<td ng-bind="item.category_name" ng-click="getSecondCategoryList(item.category_cd)"></td>
							<td ng-bind="item.access_role_name" ng-click="getSecondCategoryList(item.category_cd)"></td>
							<td class="collapsing">
								<div class="ui fitted slider checkbox">
									<input type="checkbox" ng-checked="item.use_yn"/>
									<label></label>
								</div>
							</td>
						</tr>
					</tbody>
					<tfoot class="full-width">
						<tr>
							<th colspan="4">
								<div class="ui right floated small primary labeled icon button" ng-click="openConfigModal('1stChk')">
									<i class="setting icon"></i>설정
								</div>
							</th>
						</tr>
					</tfoot>
				</table>
			</div>
			<div class="six wide column">
				<table class="ui compact celled definition table" ng-show="secondDepthCategory!=null">
					<thead class="full-width">
						<tr>
							<th><div class="ui orange ribbon label">2nd</div></th>
							<th>카테고리</th>
							<th>보기 권한</th>
							<th>활성화</th>
						</tr>
					</thead>
					<tbody>
						<tr ng-repeat="item in secondDepthCategory">
							<td class="center aligned">
								<div class="ui checkbox">
									<input type="checkbox"/>
									<label></label>
								</div>
							</td>
							<td ng-bind="item.category_name"></td>
							<td ng-bind="item.access_role_name"></td>
							<td class="collapsing">
								<div class="ui fitted slider checkbox">
									<input type="checkbox" ng-checked="item.use_yn"/>
									<label></label>
								</div>
							</td>
						</tr>
						<tr ng-if="secondDepthCategory.length==0">
							<td class="center aligned" colspan="4"><i class="warning sign icon"></i>하위 카테고리가 없습니다.</td>
						</tr>
					</tbody>
					<tfoot class="full-width">
						<tr>
							<th colspan="4">
								<div class="ui right floated small primary labeled icon button">
									<i class="setting icon"></i>설정
								</div>
							</th>
						</tr>
					</tfoot>
				</table>
			</div>
		</div>
	</div>
	<content tag="script">
		<script>
			$('div.dropdown').dropdown();

			var app = angular.module('categoryApp', []);
			app.controller('categoryCtrl', ['$scope','$http','$q',function($scope, $http, $q){
				var createParamObj = function(depth, parentCategoryCd){
					this.depth = depth;
					this.parent_category_cd = parentCategoryCd;
				};

				var getTree = function(data){
					var promises = new Array();
					data.forEach(v => { promises.push(getList(2, v.category_cd)); });
					$q.all(promises).then(results => {
						angular.forEach(results, (item, index) => {
							angular.extend(data[index], {children:item.data});
						});
						angular.element('.ui.radio.checkbox').checkbox();
						$scope.tree = data;
					});
				};

				var getList = function(depth, parentCategoryCd){
					return $http({
						method:'get',
						url:'/api/categoryList',
						params:new createParamObj(depth, parentCategoryCd)
					});
				};

				getList(1, null).then(result => {
					$scope.firstDepthCategory = result.data;
					getTree(result.data);
				});

				$scope.getSecondCategoryList = function(parentCategoryCd){
					getList(2, parentCategoryCd).then(result => {
						$scope.secondDepthCategory = result.data;
					});
				};

				$scope.openConfigModal = function(chkBoxEleName){
					var index = angular.element('input[name='+chkBoxEleName+']:checked').val();
					$scope.popupData = $scope.firstDepthCategory[index];
					if($scope.roleList==null){
						$http({
							method:'get',
							url:'/api/codeList',
							params:{up_cd:'ROLE'}
						}).then(function(result){
							$scope.roleList = result.data;
							angular.element('.small.modal').modal('show');
						});
					} else {
						angular.element('.small.modal').modal('show');
					}
				};


			}]);
		</script>
	</content>
</body>
</html>
